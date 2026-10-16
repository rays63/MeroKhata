import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Writes a single-sheet .xlsx (Office Open XML) workbook.
///
/// Strings are stored inline and numbers as numbers, so Excel, Numbers and
/// Google Sheets can total the amount columns. The first row is bold.
Uint8List writeXlsx({
  required String sheetName,
  required List<String> headers,
  required List<List<Object>> rows,
}) {
  final sheet = StringBuffer()
    ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    ..write(
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
    )
    ..write('<sheetData>');
  void writeRow(int index, List<Object> cells, {bool header = false}) {
    sheet.write('<row r="$index">');
    for (var col = 0; col < cells.length; col++) {
      final ref = '${_column(col)}$index';
      final value = cells[col];
      final style = header ? ' s="1"' : '';
      if (value is num) {
        sheet.write('<c r="$ref"$style><v>$value</v></c>');
      } else {
        sheet.write(
          '<c r="$ref" t="inlineStr"$style><is><t xml:space="preserve">'
          '${_escape(value.toString())}</t></is></c>',
        );
      }
    }
    sheet.write('</row>');
  }

  writeRow(1, headers, header: true);
  for (var i = 0; i < rows.length; i++) {
    writeRow(i + 2, rows[i]);
  }
  sheet.write('</sheetData></worksheet>');

  final truncated = _escape(_sheetName(sheetName));

  final files = <String, String>{
    '[Content_Types].xml':
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
        '</Types>',
    '_rels/.rels':
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
        '</Relationships>',
    'xl/workbook.xml':
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<sheets><sheet name="$truncated" sheetId="1" r:id="rId1"/></sheets>'
        '</workbook>',
    'xl/_rels/workbook.xml.rels':
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
        '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        '</Relationships>',
    'xl/styles.xml':
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
        '<font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
        '<fills count="2"><fill><patternFill patternType="none"/></fill>'
        '<fill><patternFill patternType="gray125"/></fill></fills>'
        '<borders count="1"><border/></borders>'
        '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
        '<cellXfs count="2"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
        '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/></cellXfs>'
        '</styleSheet>',
    'xl/worksheets/sheet1.xml': sheet.toString(),
  };

  final archive = Archive();
  for (final MapEntry(key: name, value: content) in files.entries) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

/// Excel sheet names: no `\ / ? * [ ] :`, no leading/trailing apostrophe,
/// at most 31 characters (counted before escaping, by character not unit).
String _sheetName(String name) {
  final cleaned = name
      .replaceAll(RegExp(r'[\\/?*\[\]:]'), ' ')
      .trim()
      .replaceAll(RegExp(r"^'+|'+$"), '')
      .trim();
  final runes = cleaned.runes.toList();
  final cut = String.fromCharCodes(runes.take(31)).trim();
  return cut.isEmpty ? 'Sheet1' : cut;
}

/// 0 → A, 25 → Z, 26 → AA.
String _column(int index) {
  var n = index + 1;
  final letters = StringBuffer();
  while (n > 0) {
    final rem = (n - 1) % 26;
    letters.write(String.fromCharCode(65 + rem));
    n = (n - 1) ~/ 26;
  }
  return letters.toString().split('').reversed.join();
}

String _escape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    // Control characters other than tab/newline aren't allowed in XML.
    .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
