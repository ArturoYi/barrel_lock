/// 各平台生命周期触发矩阵（差异版 rawState → 典型触发场景）。
///
/// 用于架构查阅与抹平层映射对照；**不代表运行时状态机唯一路径**，
/// 实际事件顺序因平台、系统版本、用户操作而异。
abstract final class LifecycleTriggerReference {
  /// iOS：单轨 Application 级，顺序大致为
  /// detached → resumed ⇄ inactive → paused → resumed。
  static const iosSequence = [
    'applicationDidFinishLaunching',
    'applicationDidBecomeActive',
    'applicationWillResignActive',
    'applicationDidEnterBackground',
    'applicationWillEnterForeground',
    'applicationWillTerminate',
  ];

  /// Android 进程层：App 前后台主轨。
  static const androidProcessSequence = [
    'ON_CREATE',
    'ON_START',
    'ON_RESUME',
    'ON_PAUSE',
    'ON_STOP',
    'ON_DESTROY',
  ];

  /// Android Activity 层：页面可见性轨（可与进程层交错）。
  static const androidActivitySequence = [
    'ON_CREATE',
    'ON_START',
    'ON_RESUME',
    'ON_PAUSE',
    'ON_STOP',
    'ON_DESTROY',
  ];

  /// 典型场景：按 Home 键
  /// - Activity: ON_PAUSE → ON_STOP
  /// - Process: ON_PAUSE → ON_STOP（几乎同时，scope 不同）
  static const androidHomeKeyScenario = '''
Activity: ON_PAUSE → ON_STOP
Process:  ON_PAUSE → ON_STOP
''';

  /// 典型场景：弹出系统对话框覆盖 App
  /// - Activity: ON_PAUSE（Process 可能仍为 ON_RESUME）
  static const androidDialogScenario = '''
Activity: ON_PAUSE
Process:  保持 ON_RESUME
''';

  /// macOS 窗口轨 + App 全局轨可并行。
  static const macosWindowSequence = [
    'NSWindowDidBecomeKeyNotification',
    'NSWindowDidResignKeyNotification',
    'NSWindowDidMiniaturizeNotification',
    'NSWindowDidDeminiaturizeNotification',
    'NSWindowWillCloseNotification',
  ];

  static const macosApplicationSequence = [
    'NSApplicationDidHideNotification',
    'NSApplicationDidUnhideNotification',
  ];

  /// Linux / Web 以窗口或标签页焦点、可见性为主。
  static const linuxWindowSequence = [
    'window_focus',
    'window_blur',
    'window_minimize',
    'window_restore',
    'window_close',
  ];

  static const webBrowserSequence = [
    'visibilitychange_visible',
    'visibilitychange_hidden',
    'window_focus',
    'window_blur',
    'pagehide',
    'pageshow',
    'page_freeze',
    'page_resume',
    'beforeunload',
  ];

  /// 抹平层与 [AppLifecycleState] 四态对照（对齐 [WidgetsBindingObserver]）。
  static const flatPhaseMapping = {
    'detached':
        'iOS didFinishLaunching/willTerminate；Android ON_CREATE/ON_DESTROY；Web beforeunload',
    'inactive':
        'iOS willResignActive；Android Activity ON_PAUSE；Web visible+blur；桌面窗口失焦',
    'resumed': 'iOS didBecomeActive；Android ON_RESUME；Web visible+focus；桌面窗口获焦',
    'paused':
        'iOS didEnterBackground；Android ON_STOP；Web tab hidden/pagefreeze；桌面最小化',
  };

  /// Web 复合推导：visible + focused → resumed；visible + blur → inactive；hidden → paused。
  static const webCompositeScenario = '''
visible + focus  → resumed
visible + blur   → inactive（切换标签页）
hidden           → paused
beforeunload     → detached
pagefreeze       → paused
''';
}
