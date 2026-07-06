/// 应用与设备信息的不可变快照（跨平台归一化视图）。
final class AppDeviceInfoSnapshot {
  const AppDeviceInfoSnapshot({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    this.buildSignature = '',
    this.installerStore,
    required this.platform,
    this.deviceModel,
    this.osVersion,
    this.isPhysicalDevice,
  });

  /// 应用显示名称。
  final String appName;

  /// 包名 / Bundle ID。
  final String packageName;

  /// 语义化版本号（如 `1.2.3`）。
  final String version;

  /// 构建号（如 `456`）。
  final String buildNumber;

  /// 签名信息（Android 等平台可用）。
  final String buildSignature;

  /// 安装来源（如 App Store、Play Store）。
  final String? installerStore;

  /// 当前运行平台。
  final AppDeviceInfoPlatform platform;

  /// 设备型号或友好名称（如 `iPhone 16 Pro`、`MacBook Pro`）。
  final String? deviceModel;

  /// 操作系统版本（如 `17.2`、`14`）。
  final String? osVersion;

  /// 是否物理设备；模拟器 / 虚拟机为 `false`，Web 等平台为 `null`。
  final bool? isPhysicalDevice;

  /// 设置页常用展示：`1.2.3 (456)`。
  String get versionLabel => '$version ($buildNumber)';

  /// 平台 + 系统版本摘要（如 `iOS 17.2`）。
  String? get osDescription {
    final os = osVersion;
    if (os == null || os.isEmpty) {
      return platform.label;
    }
    return '${platform.label} $os';
  }
}

/// 归一化平台枚举，供业务层 switch，不暴露各平台原生 DeviceInfo 类型。
enum AppDeviceInfoPlatform {
  ios('iOS'),
  android('Android'),
  macos('macOS'),
  windows('Windows'),
  linux('Linux'),
  web('Web'),
  unknown('Unknown');

  const AppDeviceInfoPlatform(this.label);

  final String label;
}
