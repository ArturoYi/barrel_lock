import 'app_device_info_reader.dart';
import 'app_device_info_snapshot.dart';

export 'app_device_info_snapshot.dart';

/// 应用设备信息门面，业务层唯一调用入口。
///
/// 类比 [AppPreference]：页面 / Provider 只依赖此类，不直接接触 [AppDeviceInfoReader]
/// 或 `package_info_plus` / `device_info_plus`。
final class AppDeviceInfo {
  AppDeviceInfo._();

  /// 初始化，App 启动时与 [SPStorage.init] 一并执行。
  static Future<void> init() => AppDeviceInfoReader.init();

  /// 重新拉取并返回最新快照。
  static Future<AppDeviceInfoSnapshot> refresh() =>
      AppDeviceInfoReader.refresh();

  /// 当前缓存快照；未 [init] 时抛 [StateError]。
  static AppDeviceInfoSnapshot get snapshot => AppDeviceInfoReader.snapshot;

  // ===================== 常用只读快捷访问 =====================

  static String get appName => snapshot.appName;

  static String get packageName => snapshot.packageName;

  static String get version => snapshot.version;

  static String get buildNumber => snapshot.buildNumber;

  /// 设置页展示：`1.2.3 (456)`。
  static String get versionLabel => snapshot.versionLabel;

  static AppDeviceInfoPlatform get platform => snapshot.platform;

  static String? get deviceModel => snapshot.deviceModel;

  static String? get osVersion => snapshot.osVersion;

  static String? get osDescription => snapshot.osDescription;

  static bool? get isPhysicalDevice => snapshot.isPhysicalDevice;
}
