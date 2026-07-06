import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_device_info_snapshot.dart';

/// 底层设备信息读取器，只封装 [package_info_plus] / [device_info_plus] 原生能力。
///
/// 类比 [SPStorage]：业务层请通过 [AppDeviceInfo] 访问，不要直接依赖本类。
final class AppDeviceInfoReader {
  AppDeviceInfoReader._();

  static AppDeviceInfoSnapshot? _snapshot;
  static DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// 启动时执行一次，拉取并缓存应用与设备信息。
  static Future<void> init({DeviceInfoPlugin? deviceInfoPlugin}) async {
    if (deviceInfoPlugin != null) {
      _deviceInfoPlugin = deviceInfoPlugin;
    }
    _snapshot = await _load();
  }

  /// 重新拉取平台信息并刷新缓存（如 OTA 后需更新版本号时调用）。
  static Future<AppDeviceInfoSnapshot> refresh() async {
    _snapshot = await _load();
    return _snapshot!;
  }

  static AppDeviceInfoSnapshot get snapshot {
    if (_snapshot == null) {
      throw StateError(
        'AppDeviceInfoReader 未初始化，请在 main 先执行 AppDeviceInfo.init()',
      );
    }
    return _snapshot!;
  }

  @visibleForTesting
  static void debugReset() {
    _snapshot = null;
    _deviceInfoPlugin = DeviceInfoPlugin();
  }

  /// 测试专用：直接注入快照，跳过平台通道。
  @visibleForTesting
  static void debugSetSnapshot(AppDeviceInfoSnapshot snapshot) {
    _snapshot = snapshot;
  }

  /// 测试专用：验证各平台 [BaseDeviceInfo] 到快照的映射逻辑。
  @visibleForTesting
  static AppDeviceInfoSnapshot mapSnapshotForTesting({
    required PackageInfo packageInfo,
    required BaseDeviceInfo deviceInfo,
  }) => _mapSnapshot(packageInfo, deviceInfo);

  static Future<AppDeviceInfoSnapshot> _load() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = await _deviceInfoPlugin.deviceInfo;
    return _mapSnapshot(packageInfo, deviceInfo);
  }

  static AppDeviceInfoSnapshot _mapSnapshot(
    PackageInfo packageInfo,
    BaseDeviceInfo deviceInfo,
  ) {
    final platformFields = _mapPlatformFields(deviceInfo);

    return AppDeviceInfoSnapshot(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildSignature: packageInfo.buildSignature,
      installerStore: packageInfo.installerStore,
      platform: platformFields.platform,
      deviceModel: platformFields.deviceModel,
      osVersion: platformFields.osVersion,
      isPhysicalDevice: platformFields.isPhysicalDevice,
    );
  }

  static _PlatformFields _mapPlatformFields(BaseDeviceInfo deviceInfo) {
    return switch (deviceInfo) {
      AndroidDeviceInfo info => _PlatformFields(
        platform: AppDeviceInfoPlatform.android,
        deviceModel: _joinNonEmpty([
          info.manufacturer,
          info.model,
        ], separator: ' '),
        osVersion: info.version.release,
        isPhysicalDevice: info.isPhysicalDevice,
      ),
      IosDeviceInfo info => _PlatformFields(
        platform: AppDeviceInfoPlatform.ios,
        deviceModel: info.modelName.isNotEmpty ? info.modelName : info.model,
        osVersion: info.systemVersion,
        isPhysicalDevice: info.isPhysicalDevice,
      ),
      MacOsDeviceInfo info => _PlatformFields(
        platform: AppDeviceInfoPlatform.macos,
        deviceModel: info.modelName.isNotEmpty ? info.modelName : info.model,
        osVersion: info.osRelease,
        isPhysicalDevice: null,
      ),
      WindowsDeviceInfo info => _PlatformFields(
        platform: AppDeviceInfoPlatform.windows,
        deviceModel: info.productName,
        osVersion: info.displayVersion.isNotEmpty
            ? info.displayVersion
            : '${info.majorVersion}.${info.minorVersion}.${info.buildNumber}',
        isPhysicalDevice: null,
      ),
      LinuxDeviceInfo info => _PlatformFields(
        platform: AppDeviceInfoPlatform.linux,
        deviceModel: info.prettyName,
        osVersion: info.version,
        isPhysicalDevice: null,
      ),
      WebBrowserInfo info => _PlatformFields(
        platform: AppDeviceInfoPlatform.web,
        deviceModel: info.browserName.name,
        osVersion: info.platform,
        isPhysicalDevice: null,
      ),
      _ => const _PlatformFields(platform: AppDeviceInfoPlatform.unknown),
    };
  }

  static String? _joinNonEmpty(
    List<String?> parts, {
    required String separator,
  }) {
    final values = parts
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (values.isEmpty) {
      return null;
    }
    return values.join(separator);
  }
}

final class _PlatformFields {
  const _PlatformFields({
    required this.platform,
    this.deviceModel,
    this.osVersion,
    this.isPhysicalDevice,
  });

  final AppDeviceInfoPlatform platform;
  final String? deviceModel;
  final String? osVersion;
  final bool? isPhysicalDevice;
}
