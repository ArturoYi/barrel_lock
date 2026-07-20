import 'package:uuid/uuid.dart';

/// 全局 UUID 生成入口，供 vault / cipher 等业务主键使用。
abstract final class AppIds {
  AppIds._();

  static const _uuid = Uuid();

  /// 生成 RFC 4122 v4 UUID 字符串。
  static String newUuid() => _uuid.v4();
}
