import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';

/// Why a file couldn't be restored. In every case nothing was changed.
enum BackupProblem {
  /// Not a .pfbak file at all (a PDF, a photo, a statement).
  notBackup,

  /// A .pfbak that is cut short or altered.
  damaged,

  /// Made by a newer Paisa Flow than this one.
  newerVersion,

  /// Password-protected and the password didn't open it.
  wrongPassword,
}

class BackupException implements Exception {
  const BackupException(this.problem, {this.appVersion});

  final BackupProblem problem;

  /// The app version that made the file, for [BackupProblem.newerVersion].
  final String? appVersion;

  @override
  String toString() => 'BackupException(${problem.name})';
}

/// What the readable header of a backup says, before it is opened.
class BackupInfo {
  const BackupInfo({
    required this.formatVersion,
    required this.appVersion,
    required this.createdAt,
    required this.protected,
  });

  final int formatVersion;
  final String appVersion;
  final DateTime createdAt;

  /// Needs the user's password to open.
  final bool protected;
}

/// Paisa Flow's own backup file (".pfbak").
///
/// Layout: the ASCII magic "PFBAK", one format-version byte, a 4-byte
/// big-endian header length, the header as JSON, then the data: gzip-ed JSON
/// sealed with AES-256-GCM (12-byte nonce, then ciphertext, then 16-byte
/// MAC). The header holds no financial data and is authenticated as
/// associated data, so it can't be changed without the file failing to open.
///
/// Without a password the key is built into the app, which keeps the file
/// unreadable to other apps but not to someone with Paisa Flow. With a
/// password the key comes from PBKDF2-HMAC-SHA256 over the password.
class BackupCodec {
  static const magic = 'PFBAK';
  static const formatVersion = 1;
  static const _pbkdf2Iterations = 120000;

  // Not a secret from anyone who takes the app apart; see the class docs.
  static const _appKey = <int>[
    0x50, 0x46, 0x2d, 0x31, 0x9c, 0x4e, 0x7a, 0x02, //
    0xd3, 0x61, 0x18, 0xbf, 0x5e, 0x90, 0x2c, 0x77,
    0x0b, 0xe4, 0x83, 0x3a, 0xc9, 0x16, 0x6d, 0xf1,
    0x42, 0xa8, 0x05, 0x9e, 0x37, 0xdb, 0x60, 0x2f,
  ];

  static final _aes = AesGcm.with256bits();

  /// Seals [data] into a backup file.
  static Future<Uint8List> encode(
    Map<String, Object?> data, {
    String? password,
    required String appVersion,
    DateTime? now,
  }) async {
    final protected = password != null && password.isNotEmpty;
    final salt = protected ? _random(16) : const <int>[];
    final header = utf8.encode(
      jsonEncode({
        'format': formatVersion,
        'app': appVersion,
        'created': (now ?? DateTime.now()).toIso8601String(),
        'protected': protected,
        if (protected) 'salt': base64Encode(salt),
        if (protected) 'iterations': _pbkdf2Iterations,
      }),
    );
    final key = await _key(password: protected ? password : null, salt: salt);
    final packed = GZipEncoder().encode(utf8.encode(jsonEncode(data)))!;
    final box = await _aes.encrypt(
      packed,
      secretKey: key,
      nonce: _aes.newNonce(),
      aad: header,
    );
    final out = BytesBuilder()
      ..add(ascii.encode(magic))
      ..addByte(formatVersion)
      ..add(_uint32(header.length))
      ..add(header)
      ..add(box.concatenation());
    return out.toBytes();
  }

  /// Reads the header. Throws [BackupException] for files that aren't
  /// backups, are damaged, or come from a newer app.
  static BackupInfo readInfo(Uint8List bytes) => _split(bytes).$1;

  /// Opens a backup. Throws [BackupException] ([BackupProblem.wrongPassword]
  /// when a protected file doesn't open with [password]).
  static Future<Map<String, Object?>> decode(
    Uint8List bytes, {
    String? password,
  }) async {
    final (info, header, sealed, salt, iterations) = _split(bytes);
    if (info.protected && (password == null || password.isEmpty)) {
      throw const BackupException(BackupProblem.wrongPassword);
    }
    final key = await _key(
      password: info.protected ? password : null,
      salt: salt,
      iterations: iterations,
    );
    final List<int> packed;
    try {
      packed = await _aes.decrypt(
        SecretBox.fromConcatenation(
          sealed,
          nonceLength: 12,
          macLength: 16,
          copy: true,
        ),
        secretKey: key,
        aad: header,
      );
    } on SecretBoxAuthenticationError {
      throw BackupException(
        info.protected ? BackupProblem.wrongPassword : BackupProblem.damaged,
      );
    } catch (_) {
      throw const BackupException(BackupProblem.damaged);
    }
    try {
      final json = utf8.decode(GZipDecoder().decodeBytes(packed));
      return (jsonDecode(json) as Map).cast<String, Object?>();
    } catch (_) {
      throw const BackupException(BackupProblem.damaged);
    }
  }

  static (BackupInfo, List<int>, List<int>, List<int>, int) _split(
    Uint8List bytes,
  ) {
    if (bytes.length < magic.length + 5 ||
        ascii.decode(bytes.sublist(0, magic.length), allowInvalid: true) !=
            magic) {
      throw const BackupException(BackupProblem.notBackup);
    }
    final version = bytes[magic.length];
    final length = ByteData.sublistView(
      bytes,
      magic.length + 1,
      magic.length + 5,
    ).getUint32(0);
    final start = magic.length + 5;
    if (start + length > bytes.length) {
      throw const BackupException(BackupProblem.damaged);
    }
    final header = bytes.sublist(start, start + length);
    final Map<String, Object?> json;
    try {
      json = (jsonDecode(utf8.decode(header)) as Map).cast();
    } catch (_) {
      throw const BackupException(BackupProblem.damaged);
    }
    final app = json['app'] as String? ?? '';
    if (version > formatVersion ||
        (json['format'] as int? ?? version) > formatVersion) {
      throw BackupException(BackupProblem.newerVersion, appVersion: app);
    }
    final sealed = bytes.sublist(start + length);
    // Nonce + at least an empty gzip stream + MAC.
    if (sealed.length < 12 + 16 + 1) {
      throw const BackupException(BackupProblem.damaged);
    }
    final info = BackupInfo(
      formatVersion: version,
      appVersion: app,
      createdAt:
          DateTime.tryParse(json['created'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      protected: json['protected'] == true,
    );
    final salt = info.protected
        ? base64Decode(json['salt'] as String? ?? '')
        : const <int>[];
    final iterations = json['iterations'] as int? ?? _pbkdf2Iterations;
    return (info, header, sealed, salt, iterations);
  }

  static Future<SecretKey> _key({
    String? password,
    required List<int> salt,
    int iterations = _pbkdf2Iterations,
  }) async {
    if (password == null) return SecretKey(_appKey);
    // PBKDF2 is deliberately slow; keep it off the UI thread.
    final bytes = await Isolate.run(() async {
      final derived = await Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: 256,
      ).deriveKeyFromPassword(password: password, nonce: salt);
      return derived.extractBytes();
    });
    return SecretKey(bytes);
  }

  static List<int> _random(int length) =>
      SecretKeyData.random(length: length).bytes;

  static List<int> _uint32(int value) =>
      (ByteData(4)..setUint32(0, value)).buffer.asUint8List();
}
