import 'dart:typed_data';

/// Minimal reader for legacy binary Excel (.xls, BIFF8 inside an OLE2
/// compound file). `spreadsheet_decoder` only understands .xlsx/.ods, while
/// some wallets (e.g. eSewa) still export the old format.
///
/// Returns every sheet as rows of cell strings. Only cell values are read;
/// formatting is ignored.
class LegacyXlsReader {
  const LegacyXlsReader._();

  static const _signature = [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1];

  static bool isLegacyXls(List<int> bytes) {
    if (bytes.length < 512) return false;
    for (var i = 0; i < _signature.length; i++) {
      if (bytes[i] != _signature[i]) return false;
    }
    return true;
  }

  static List<List<List<String>>> read(List<int> input) {
    final bytes = input is Uint8List ? input : Uint8List.fromList(input);
    final workbook = _readWorkbookStream(bytes);
    return _readSheets(workbook);
  }

  // ---------------------------------------------------------------------------
  // OLE2 compound file
  // ---------------------------------------------------------------------------

  static const _endOfChain = 0xFFFFFFFE;
  static const _freeSector = 0xFFFFFFFF;

  static Uint8List _readWorkbookStream(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    final sectorSize = 1 << data.getUint16(0x1E, Endian.little);
    final miniSectorSize = 1 << data.getUint16(0x20, Endian.little);
    final fatSectorCount = data.getUint32(0x2C, Endian.little);
    final firstDirectorySector = data.getUint32(0x30, Endian.little);
    final miniStreamCutoff = data.getUint32(0x38, Endian.little);
    final firstMiniFatSector = data.getUint32(0x3C, Endian.little);
    var difatSector = data.getUint32(0x44, Endian.little);

    int sectorOffset(int sector) => (sector + 1) * sectorSize;

    // Collect FAT sector numbers from the header DIFAT and any DIFAT chain.
    final fatSectors = <int>[];
    for (var i = 0; i < 109 && fatSectors.length < fatSectorCount; i++) {
      final sector = data.getUint32(0x4C + i * 4, Endian.little);
      if (sector == _freeSector) break;
      fatSectors.add(sector);
    }
    final perDifat = sectorSize ~/ 4 - 1;
    while (difatSector != _endOfChain &&
        difatSector != _freeSector &&
        fatSectors.length < fatSectorCount) {
      final offset = sectorOffset(difatSector);
      for (var i = 0; i < perDifat && fatSectors.length < fatSectorCount; i++) {
        fatSectors.add(data.getUint32(offset + i * 4, Endian.little));
      }
      difatSector = data.getUint32(offset + perDifat * 4, Endian.little);
    }

    final fat = <int>[];
    for (final sector in fatSectors) {
      final offset = sectorOffset(sector);
      for (var i = 0; i < sectorSize ~/ 4; i++) {
        fat.add(data.getUint32(offset + i * 4, Endian.little));
      }
    }

    Uint8List readChain(int start, {int? size}) {
      final builder = BytesBuilder(copy: false);
      var sector = start;
      var guard = 0;
      while (sector != _endOfChain && sector < fat.length) {
        final offset = sectorOffset(sector);
        final end = offset + sectorSize;
        if (end > bytes.length) break;
        builder.add(Uint8List.sublistView(bytes, offset, end));
        sector = fat[sector];
        if (++guard > fat.length) throw const FormatException('Corrupt FAT');
      }
      final all = builder.takeBytes();
      return size == null || size > all.length
          ? all
          : Uint8List.sublistView(all, 0, size);
    }

    final directory = readChain(firstDirectorySector);
    final dirData = ByteData.sublistView(directory);
    Uint8List? rootStream;
    for (var offset = 0; offset + 128 <= directory.length; offset += 128) {
      final nameLength = dirData.getUint16(offset + 0x40, Endian.little);
      final type = directory[offset + 0x42];
      if (nameLength < 2 || type == 0) continue;
      final name = String.fromCharCodes([
        for (var i = 0; i < nameLength - 2; i += 2)
          dirData.getUint16(offset + i, Endian.little),
      ]);
      final start = dirData.getUint32(offset + 0x74, Endian.little);
      final size = dirData.getUint32(offset + 0x78, Endian.little);
      if (type == 5) {
        rootStream = readChain(start, size: size);
        continue;
      }
      if (type != 2 || (name != 'Workbook' && name != 'Book')) continue;
      if (size >= miniStreamCutoff) return readChain(start, size: size);

      // Small streams live in the mini stream (inside the root entry).
      final miniFatBytes = readChain(firstMiniFatSector);
      final miniFat = ByteData.sublistView(miniFatBytes);
      final miniStream = rootStream ?? Uint8List(0);
      final builder = BytesBuilder(copy: false);
      var sector = start;
      while (sector != _endOfChain && builder.length < size) {
        final from = sector * miniSectorSize;
        if (from + miniSectorSize > miniStream.length) break;
        builder.add(
          Uint8List.sublistView(miniStream, from, from + miniSectorSize),
        );
        if (sector * 4 + 4 > miniFatBytes.length) break;
        sector = miniFat.getUint32(sector * 4, Endian.little);
      }
      final all = builder.takeBytes();
      return Uint8List.sublistView(all, 0, size.clamp(0, all.length));
    }
    throw const FormatException('No Workbook stream found in .xls file');
  }

  // ---------------------------------------------------------------------------
  // BIFF8 records
  // ---------------------------------------------------------------------------

  static const _bof = 0x0809;
  static const _eof = 0x000A;
  static const _continue = 0x003C;
  static const _sst = 0x00FC;
  static const _labelSst = 0x00FD;
  static const _label = 0x0204;
  static const _number = 0x0203;
  static const _rk = 0x027E;
  static const _mulRk = 0x00BD;
  static const _formula = 0x0006;
  static const _string = 0x0207;

  static List<List<List<String>>> _readSheets(Uint8List stream) {
    final data = ByteData.sublistView(stream);
    final sheets = <List<List<String>>>[];
    var sst = <String>[];
    Map<int, Map<int, String>>? cells;
    var depth = 0;
    var sheetDepth = 0;
    (int, int)? pendingFormula;

    void put(int row, int col, String value) {
      (cells![row] ??= {})[col] = value;
    }

    var offset = 0;
    while (offset + 4 <= stream.length) {
      final type = data.getUint16(offset, Endian.little);
      final length = data.getUint16(offset + 2, Endian.little);
      final body = offset + 4;
      if (body + length > stream.length) break;
      var next = body + length;

      switch (type) {
        case _bof:
          depth++;
          // Substream type 0x0010 is a worksheet.
          if (cells == null &&
              length >= 4 &&
              data.getUint16(body + 2, Endian.little) == 0x10) {
            cells = {};
            sheetDepth = depth;
          }
        case _eof:
          depth--;
          if (cells != null && depth < sheetDepth) {
            sheets.add(_toRows(cells));
            cells = null;
          }
        case _sst:
          final segments = [Uint8List.sublistView(stream, body, next)];
          while (next + 4 <= stream.length &&
              data.getUint16(next, Endian.little) == _continue) {
            final len = data.getUint16(next + 2, Endian.little);
            segments.add(
              Uint8List.sublistView(stream, next + 4, next + 4 + len),
            );
            next += 4 + len;
          }
          sst = _readSst(segments);
        case _labelSst when cells != null:
          final index = data.getUint32(body + 6, Endian.little);
          put(
            data.getUint16(body, Endian.little),
            data.getUint16(body + 2, Endian.little),
            index < sst.length ? sst[index] : '',
          );
        case _label when cells != null:
          final reader = _SegmentReader([
            Uint8List.sublistView(stream, body + 6, next),
          ]);
          put(
            data.getUint16(body, Endian.little),
            data.getUint16(body + 2, Endian.little),
            reader.readUnicodeString(),
          );
        case _number when cells != null:
          put(
            data.getUint16(body, Endian.little),
            data.getUint16(body + 2, Endian.little),
            _formatNumber(data.getFloat64(body + 6, Endian.little)),
          );
        case _rk when cells != null:
          put(
            data.getUint16(body, Endian.little),
            data.getUint16(body + 2, Endian.little),
            _formatNumber(_decodeRk(data.getUint32(body + 6, Endian.little))),
          );
        case _mulRk when cells != null:
          final row = data.getUint16(body, Endian.little);
          final first = data.getUint16(body + 2, Endian.little);
          final count = (length - 6) ~/ 6;
          for (var i = 0; i < count; i++) {
            final rk = data.getUint32(body + 4 + i * 6 + 2, Endian.little);
            put(row, first + i, _formatNumber(_decodeRk(rk)));
          }
        case _formula when cells != null:
          final row = data.getUint16(body, Endian.little);
          final col = data.getUint16(body + 2, Endian.little);
          // 0xFFFF in the top bytes marks a non-numeric result.
          if (data.getUint16(body + 12, Endian.little) != 0xFFFF) {
            put(
              row,
              col,
              _formatNumber(data.getFloat64(body + 6, Endian.little)),
            );
          } else if (stream[body + 6] == 0) {
            pendingFormula = (row, col);
          }
        case _string when cells != null && pendingFormula != null:
          final reader = _SegmentReader([
            Uint8List.sublistView(stream, body, next),
          ]);
          put(pendingFormula.$1, pendingFormula.$2, reader.readUnicodeString());
          pendingFormula = null;
      }
      offset = next;
    }
    return sheets;
  }

  static List<String> _readSst(List<Uint8List> segments) {
    final reader = _SegmentReader(segments);
    reader.skip(4); // total string count
    final unique = reader.readUint32();
    final strings = <String>[];
    for (var i = 0; i < unique && !reader.isDone; i++) {
      strings.add(reader.readUnicodeString());
    }
    return strings;
  }

  static List<List<String>> _toRows(Map<int, Map<int, String>> cells) {
    if (cells.isEmpty) return [];
    final lastRow = cells.keys.reduce((a, b) => a > b ? a : b);
    return [
      for (var row = 0; row <= lastRow; row++)
        if (cells[row] case final columns?)
          [
            for (
              var col = 0;
              col <= columns.keys.reduce((a, b) => a > b ? a : b);
              col++
            )
              columns[col] ?? '',
          ]
        else
          <String>[],
    ];
  }

  static double _decodeRk(int rk) {
    final double value;
    if (rk & 0x02 != 0) {
      value = (rk >> 2).toSigned(30).toDouble();
    } else {
      final bits = ByteData(8)..setUint32(4, rk & 0xFFFFFFFC, Endian.little);
      value = bits.getFloat64(0, Endian.little);
    }
    return rk & 0x01 != 0 ? value / 100 : value;
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}

/// Reads BIFF8 unicode strings that may be split across CONTINUE records.
class _SegmentReader {
  _SegmentReader(this._segments);

  final List<Uint8List> _segments;
  int _segment = 0;
  int _offset = 0;

  bool get isDone =>
      _segment >= _segments.length ||
      (_segment == _segments.length - 1 &&
          _offset >= _segments[_segment].length);

  int _byte() {
    while (_segment < _segments.length &&
        _offset >= _segments[_segment].length) {
      _segment++;
      _offset = 0;
    }
    if (_segment >= _segments.length) {
      throw const FormatException('Unexpected end of .xls string data');
    }
    return _segments[_segment][_offset++];
  }

  int readUint16() => _byte() | (_byte() << 8);

  int readUint32() => readUint16() | (readUint16() << 16);

  void skip(int count) {
    for (var i = 0; i < count; i++) {
      _byte();
    }
  }

  String readUnicodeString() {
    final length = readUint16();
    final flags = _byte();
    var highByte = flags & 0x01 != 0;
    final runs = flags & 0x08 != 0 ? readUint16() : 0;
    final extSize = flags & 0x04 != 0 ? readUint32() : 0;
    final codes = <int>[];
    while (codes.length < length) {
      if (_segment < _segments.length - 1 &&
          _offset >= _segments[_segment].length) {
        // Characters continue in the next record, which restates the width.
        _segment++;
        _offset = 0;
        highByte = _byte() & 0x01 != 0;
      }
      codes.add(highByte ? readUint16() : _byte());
    }
    skip(runs * 4 + extSize);
    return String.fromCharCodes(codes);
  }
}
