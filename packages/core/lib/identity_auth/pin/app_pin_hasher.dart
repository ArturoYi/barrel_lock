import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// 应用内 PIN 的 PBKDF2-HMAC-SHA256 哈希工具（内部实现，不对外导出）。
final class AppPinHasher {
  AppPinHasher._();

  static const int saltLength = 16;
  static const int hashLength = 32;
  static const int defaultIterations = 100000;

  static final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: defaultIterations,
    bits: hashLength * 8,
  );

  static Future<AppPinRecord> hashPin(String pin) async {
    final salt = List<int>.generate(
      saltLength,
      (_) => SecureRandom.fast.nextInt(256),
    );
    final hash = await _derive(pin, salt);
    return AppPinRecord(
      saltBase64: base64Encode(salt),
      hashBase64: base64Encode(hash),
      iterations: defaultIterations,
    );
  }

  static Future<bool> verifyPin({
    required String pin,
    required AppPinRecord record,
  }) async {
    final salt = base64Decode(record.saltBase64);
    final expected = base64Decode(record.hashBase64);
    final actual = await _derive(pin, salt, iterations: record.iterations);
    if (actual.length != expected.length) {
      return false;
    }

    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual[i] ^ expected[i];
    }
    return diff == 0;
  }

  static Future<List<int>> _derive(
    String pin,
    List<int> salt, {
    int iterations = defaultIterations,
  }) async {
    final algorithm = iterations == defaultIterations
        ? _pbkdf2
        : Pbkdf2(
            macAlgorithm: Hmac.sha256(),
            iterations: iterations,
            bits: hashLength * 8,
          );
    final secretKey = await algorithm.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );
    return secretKey.extractBytes();
  }
}

/// 持久化的 PIN 哈希记录。
final class AppPinRecord {
  const AppPinRecord({
    required this.saltBase64,
    required this.hashBase64,
    required this.iterations,
  });

  factory AppPinRecord.fromJson(Map<String, dynamic> json) {
    return AppPinRecord(
      saltBase64: json['salt'] as String,
      hashBase64: json['hash'] as String,
      iterations: json['iterations'] as int? ?? AppPinHasher.defaultIterations,
    );
  }

  final String saltBase64;
  final String hashBase64;
  final int iterations;

  Map<String, dynamic> toJson() => {
    'salt': saltBase64,
    'hash': hashBase64,
    'iterations': iterations,
  };

  String toJsonString() => jsonEncode(toJson());
}
