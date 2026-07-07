import '../life_platform_source.dart';
import '../lifecycle_scope.dart';
import '../raw_lifecycle_event.dart';
import '../states/android_app_lifecycle_state.dart';
import '../states/ios_app_lifecycle_state.dart';
import '../states/linux_app_lifecycle_state.dart';
import '../states/macos_app_lifecycle_state.dart';
import '../states/web_app_lifecycle_state.dart';
import 'flat_lifecycle_phase.dart';

/// 抹平映射器内部状态（Android 双层 + Web 可见性/焦点复合推导）。
final class FlatLifecycleMapperState {
  const FlatLifecycleMapperState({
    this.lastPhase = FlatLifecyclePhase.unknown,
    this.androidProcessState,
    this.androidActivityState,
    this.webPageVisible,
    this.webPageFocused,
    this.webPagePersisted,
  });

  static const empty = FlatLifecycleMapperState();

  final FlatLifecyclePhase lastPhase;
  final String? androidProcessState;
  final String? androidActivityState;
  final bool? webPageVisible;
  final bool? webPageFocused;
  final bool? webPagePersisted;

  FlatLifecycleMapperState copyWith({
    FlatLifecyclePhase? lastPhase,
    String? androidProcessState,
    String? androidActivityState,
    bool? webPageVisible,
    bool? webPageFocused,
    bool? webPagePersisted,
  }) {
    return FlatLifecycleMapperState(
      lastPhase: lastPhase ?? this.lastPhase,
      androidProcessState: androidProcessState ?? this.androidProcessState,
      androidActivityState: androidActivityState ?? this.androidActivityState,
      webPageVisible: webPageVisible ?? this.webPageVisible,
      webPageFocused: webPageFocused ?? this.webPageFocused,
      webPagePersisted: webPagePersisted ?? this.webPagePersisted,
    );
  }
}

/// 将 [RawLifeCycleEvent] 映射为 [FlatLifecyclePhase]（对齐 [WidgetsBindingObserver]）。
///
/// 仅在抹平层使用；不改变原生事件，不替代平台差异版 Mixin。
abstract final class FlatLifecycleMapper {
  static FlatLifecycleMapperState apply(
    RawLifeCycleEvent event,
    FlatLifecycleMapperState state,
  ) {
    var nextState = _updatePlatformState(event, state);
    final phase = _resolvePhase(event, nextState);
    return nextState.copyWith(lastPhase: phase);
  }

  static FlatLifecyclePhase resolve(
    RawLifeCycleEvent event,
    FlatLifecycleMapperState state,
  ) {
    return apply(event, state).lastPhase;
  }

  static FlatLifecycleMapperState _updatePlatformState(
    RawLifeCycleEvent event,
    FlatLifecycleMapperState state,
  ) {
    return switch (event.source) {
      LifePlatformSource.android => _updateAndroidState(event, state),
      LifePlatformSource.web => _updateWebState(event, state),
      _ => state,
    };
  }

  static FlatLifecycleMapperState _updateAndroidState(
    RawLifeCycleEvent event,
    FlatLifecycleMapperState state,
  ) {
    switch (event.extra.lifecycleScope) {
      case LifecycleScope.process:
        return state.copyWith(androidProcessState: event.rawState);
      case LifecycleScope.activity:
        return state.copyWith(androidActivityState: event.rawState);
      default:
        return state;
    }
  }

  static FlatLifecycleMapperState _updateWebState(
    RawLifeCycleEvent event,
    FlatLifecycleMapperState state,
  ) {
    switch (event.rawState) {
      case WebAppLifecycleState.visibilityChangeHidden:
        return state.copyWith(webPageVisible: false);
      case WebAppLifecycleState.visibilityChangeVisible:
      case WebAppLifecycleState.pageShow:
        return state.copyWith(webPageVisible: true);
      case WebAppLifecycleState.windowFocus:
      case WebAppLifecycleState.pageResume:
        return state.copyWith(webPageFocused: true);
      case WebAppLifecycleState.windowBlur:
        return state.copyWith(webPageFocused: false);
      case WebAppLifecycleState.pageHide:
        final persisted = event.extra.metadata['persisted'];
        return state.copyWith(
          webPageVisible: false,
          webPagePersisted: persisted is bool ? persisted : null,
        );
      default:
        return state;
    }
  }

  static FlatLifecyclePhase _resolvePhase(
    RawLifeCycleEvent event,
    FlatLifecycleMapperState state,
  ) {
    return switch (event.source) {
      LifePlatformSource.ios => _mapIos(event.rawState),
      LifePlatformSource.android => _mapAndroid(state),
      LifePlatformSource.macos => _mapMacos(event),
      LifePlatformSource.linux => _mapLinux(event.rawState),
      LifePlatformSource.web => _mapWeb(event, state),
      LifePlatformSource.windows => state.lastPhase,
    };
  }

  static FlatLifecyclePhase _mapIos(String rawState) {
    return switch (rawState) {
      IosAppLifecycleState.applicationDidFinishLaunching =>
        FlatLifecyclePhase.detached,
      IosAppLifecycleState.applicationDidBecomeActive =>
        FlatLifecyclePhase.resumed,
      IosAppLifecycleState.applicationWillResignActive =>
        FlatLifecyclePhase.inactive,
      IosAppLifecycleState.applicationWillEnterForeground =>
        FlatLifecyclePhase.inactive,
      IosAppLifecycleState.applicationDidEnterBackground =>
        FlatLifecyclePhase.paused,
      IosAppLifecycleState.applicationWillTerminate =>
        FlatLifecyclePhase.detached,
      _ => FlatLifecyclePhase.unknown,
    };
  }

  /// Android：进程层决定 paused；Activity 层细化 inactive / resumed。
  static FlatLifecyclePhase _mapAndroid(FlatLifecycleMapperState state) {
    final process = state.androidProcessState;
    final activity = state.androidActivityState;

    if (process == AndroidAppLifecycleState.onDestroy ||
        activity == AndroidAppLifecycleState.onDestroy) {
      return FlatLifecyclePhase.detached;
    }
    if (process == AndroidAppLifecycleState.onCreate ||
        activity == AndroidAppLifecycleState.onCreate) {
      return FlatLifecyclePhase.detached;
    }
    if (process == AndroidAppLifecycleState.onStop ||
        activity == AndroidAppLifecycleState.onStop) {
      return FlatLifecyclePhase.paused;
    }
    if (activity == AndroidAppLifecycleState.onPause) {
      return FlatLifecyclePhase.inactive;
    }
    if (process == AndroidAppLifecycleState.onPause) {
      return FlatLifecyclePhase.inactive;
    }
    if (activity == AndroidAppLifecycleState.onResume) {
      return FlatLifecyclePhase.resumed;
    }
    if (process == AndroidAppLifecycleState.onResume) {
      return FlatLifecyclePhase.resumed;
    }
    if (process == AndroidAppLifecycleState.onStart ||
        activity == AndroidAppLifecycleState.onStart) {
      return FlatLifecyclePhase.inactive;
    }
    return state.lastPhase;
  }

  static FlatLifecyclePhase _mapMacos(RawLifeCycleEvent event) {
    if (event.extra.lifecycleScope == LifecycleScope.application) {
      return switch (event.rawState) {
        MacosAppLifecycleState.applicationDidHide => FlatLifecyclePhase.paused,
        MacosAppLifecycleState.applicationDidUnhide =>
          FlatLifecyclePhase.resumed,
        _ => FlatLifecyclePhase.unknown,
      };
    }

    return switch (event.rawState) {
      MacosAppLifecycleState.windowDidBecomeKey => FlatLifecyclePhase.resumed,
      MacosAppLifecycleState.windowDidDeminiaturize =>
        FlatLifecyclePhase.resumed,
      MacosAppLifecycleState.windowDidResignKey => FlatLifecyclePhase.inactive,
      MacosAppLifecycleState.windowDidMiniaturize => FlatLifecyclePhase.paused,
      MacosAppLifecycleState.windowWillClose => FlatLifecyclePhase.detached,
      _ => FlatLifecyclePhase.unknown,
    };
  }

  static FlatLifecyclePhase _mapLinux(String rawState) {
    return switch (rawState) {
      LinuxAppLifecycleState.windowFocus => FlatLifecyclePhase.resumed,
      LinuxAppLifecycleState.windowRestore => FlatLifecyclePhase.resumed,
      LinuxAppLifecycleState.windowBlur => FlatLifecyclePhase.inactive,
      LinuxAppLifecycleState.windowMinimize => FlatLifecyclePhase.paused,
      LinuxAppLifecycleState.windowClose => FlatLifecyclePhase.detached,
      _ => FlatLifecyclePhase.unknown,
    };
  }

  /// Web：可见性 + 焦点复合推导，补齐 WidgetsBindingObserver 四态缺口。
  static FlatLifecyclePhase _mapWeb(
    RawLifeCycleEvent event,
    FlatLifecycleMapperState state,
  ) {
    switch (event.rawState) {
      case WebAppLifecycleState.beforeUnload:
        return FlatLifecyclePhase.detached;
      case WebAppLifecycleState.pageFreeze:
        return FlatLifecyclePhase.paused;
    }

    final visible = state.webPageVisible;
    final focused = state.webPageFocused;

    if (visible == false) {
      // pagehide / visibility hidden → paused；BFCache persisted 仍视为 paused
      return FlatLifecyclePhase.paused;
    }
    if (visible == true && focused == true) {
      return FlatLifecyclePhase.resumed;
    }
    if (visible == true && focused == false) {
      // 标签页可见但失焦（切换标签/Cmd+Tab）→ inactive
      return FlatLifecyclePhase.inactive;
    }

    return state.lastPhase;
  }
}
