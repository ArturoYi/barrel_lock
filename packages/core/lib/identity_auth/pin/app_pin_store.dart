import 'dart:convert';

import '../../preference/sp_storage.dart';
import 'app_pin_hasher.dart';

/// 应用内 PIN 哈希的 SP 存取（内部实现）。
final class AppPinStore {
  AppPinStore({required this.storageKey});

  final String storageKey;

  Future<bool> hasPin() async {
    return _readRecord() != null;
  }

  Future<void> savePin(String pin) async {
    final record = await AppPinHasher.hashPin(pin);
    await SPStorage.setString(storageKey, record.toJsonString());
  }

  Future<bool> verifyPin(String pin) async {
    final record = _readRecord();
    if (record == null) {
      return false;
    }
    return AppPinHasher.verifyPin(pin: pin, record: record);
  }

  Future<void> clearPin() async {
    await SPStorage.remove(storageKey);
  }

  AppPinRecord? _readRecord() {
    final raw = SPStorage.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppPinRecord.fromJson(map);
    } on FormatException {
      return null;
    }
  }
}
