import 'package:flutter/widgets.dart';

/// 抹平层生命周期相位，与 [AppLifecycleState] / [WidgetsBindingObserver] 四态严格对齐。
///
/// 仅在 Dart 业务层使用；原生层仍透传平台原始 [rawState]。
///
/// | 相位 | 语义（同 Flutter 官方文档） |
/// |------|---------------------------|
/// | [detached] | 未寄存在任何视图上（如 iOS 无 VC、Android 未附加 Activity） |
/// | [inactive] | 可见但无法接收用户输入（来电、权限弹窗、失焦等） |
/// | [resumed] | 前台可见且可响应用户输入 |
/// | [paused] | 后台不可见、不响应输入，随时可能被系统挂起 |
enum FlatLifecyclePhase {
  /// 尚未收到任何事件。
  unknown,

  /// ≈ [AppLifecycleState.detached]
  detached,

  /// ≈ [AppLifecycleState.inactive]
  inactive,

  /// ≈ [AppLifecycleState.resumed]
  resumed,

  /// ≈ [AppLifecycleState.paused]
  paused,
}

/// [FlatLifecyclePhase] ↔ [AppLifecycleState] 互转。
extension FlatLifecyclePhaseX on FlatLifecyclePhase {
  /// 转为 Flutter [AppLifecycleState]；[FlatLifecyclePhase.unknown] 返回 null。
  AppLifecycleState? get toAppLifecycleState {
    return switch (this) {
      FlatLifecyclePhase.resumed => AppLifecycleState.resumed,
      FlatLifecyclePhase.inactive => AppLifecycleState.inactive,
      FlatLifecyclePhase.paused => AppLifecycleState.paused,
      FlatLifecyclePhase.detached => AppLifecycleState.detached,
      FlatLifecyclePhase.unknown => null,
    };
  }

  /// 是否为 [AppLifecycleState.paused] 等价后台态。
  bool get isPausedEquivalent => this == FlatLifecyclePhase.paused;

  /// 是否为 [AppLifecycleState.resumed] 等价前台可交互态。
  bool get isResumedEquivalent => this == FlatLifecyclePhase.resumed;
}

/// [AppLifecycleState] → [FlatLifecyclePhase]。
extension AppLifecycleStateFlatX on AppLifecycleState {
  FlatLifecyclePhase get toFlatLifecyclePhase {
    return switch (this) {
      AppLifecycleState.resumed => FlatLifecyclePhase.resumed,
      AppLifecycleState.inactive => FlatLifecyclePhase.inactive,
      AppLifecycleState.paused => FlatLifecyclePhase.paused,
      AppLifecycleState.detached => FlatLifecyclePhase.detached,
      AppLifecycleState.hidden => FlatLifecyclePhase.paused,
    };
  }
}
