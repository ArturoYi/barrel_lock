/// iOS [UIApplicationDelegate] 回调名 SSOT（需求文档 §4.1）。
abstract final class IosAppLifecycleState {
  static const applicationDidFinishLaunching = 'applicationDidFinishLaunching';
  static const applicationDidBecomeActive = 'applicationDidBecomeActive';
  static const applicationWillResignActive = 'applicationWillResignActive';
  static const applicationDidEnterBackground = 'applicationDidEnterBackground';
  static const applicationWillEnterForeground =
      'applicationWillEnterForeground';
  static const applicationWillTerminate = 'applicationWillTerminate';
}
