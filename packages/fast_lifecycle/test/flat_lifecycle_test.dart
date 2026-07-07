import 'package:fast_lifecycle/fast_lifecycle.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlatLifecycleMapper', () {
    test('maps iOS delegate callbacks to AppLifecycleState semantics', () {
      const state = FlatLifecycleMapperState.empty;

      expect(
        FlatLifecycleMapper.resolve(
          const RawLifeCycleEvent(
            source: LifePlatformSource.ios,
            rawState: IosAppLifecycleState.applicationDidFinishLaunching,
            extra: LifeCycleEventExtra(
              lifecycleScope: LifecycleScope.application,
            ),
          ),
          state,
        ),
        FlatLifecyclePhase.detached,
      );
      expect(
        FlatLifecycleMapper.resolve(
          const RawLifeCycleEvent(
            source: LifePlatformSource.ios,
            rawState: IosAppLifecycleState.applicationDidBecomeActive,
            extra: LifeCycleEventExtra(
              lifecycleScope: LifecycleScope.application,
            ),
          ),
          state,
        ),
        FlatLifecyclePhase.resumed,
      );
      expect(
        FlatLifecycleMapper.resolve(
          const RawLifeCycleEvent(
            source: LifePlatformSource.ios,
            rawState: IosAppLifecycleState.applicationDidEnterBackground,
            extra: LifeCycleEventExtra(
              lifecycleScope: LifecycleScope.application,
            ),
          ),
          state,
        ),
        FlatLifecyclePhase.paused,
      );
    });

    test('maps Android process and activity with priority', () {
      var state = FlatLifecycleMapperState.empty;

      state = FlatLifecycleMapper.apply(
        const RawLifeCycleEvent(
          source: LifePlatformSource.android,
          rawState: AndroidAppLifecycleState.onResume,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.process),
        ),
        state,
      );
      state = FlatLifecycleMapper.apply(
        const RawLifeCycleEvent(
          source: LifePlatformSource.android,
          rawState: AndroidAppLifecycleState.onResume,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.activity),
        ),
        state,
      );
      expect(state.lastPhase, FlatLifecyclePhase.resumed);

      state = FlatLifecycleMapper.apply(
        const RawLifeCycleEvent(
          source: LifePlatformSource.android,
          rawState: AndroidAppLifecycleState.onPause,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.activity),
        ),
        state,
      );
      expect(state.lastPhase, FlatLifecyclePhase.inactive);

      state = FlatLifecycleMapper.apply(
        const RawLifeCycleEvent(
          source: LifePlatformSource.android,
          rawState: AndroidAppLifecycleState.onStop,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.process),
        ),
        state,
      );
      expect(state.lastPhase, FlatLifecyclePhase.paused);
    });

    test('web composite: visible+blur is inactive, hidden is paused', () {
      var state = FlatLifecycleMapperState.empty;

      state = FlatLifecycleMapper.apply(
        const RawLifeCycleEvent(
          source: LifePlatformSource.web,
          rawState: WebAppLifecycleState.visibilityChangeVisible,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.browser),
        ),
        state,
      );
      state = FlatLifecycleMapper.apply(
        const RawLifeCycleEvent(
          source: LifePlatformSource.web,
          rawState: WebAppLifecycleState.windowBlur,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.browser),
        ),
        state,
      );
      expect(state.lastPhase, FlatLifecyclePhase.inactive);

      state = FlatLifecycleMapper.apply(
        const RawLifeCycleEvent(
          source: LifePlatformSource.web,
          rawState: WebAppLifecycleState.visibilityChangeHidden,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.browser),
        ),
        state,
      );
      expect(state.lastPhase, FlatLifecyclePhase.paused);
    });

    test('web visible+focus is resumed', () {
      var state = FlatLifecycleMapperState.empty;

      state = FlatLifecycleMapper.apply(
        const RawLifeCycleEvent(
          source: LifePlatformSource.web,
          rawState: WebAppLifecycleState.visibilityChangeVisible,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.browser),
        ),
        state,
      );
      state = FlatLifecycleMapper.apply(
        const RawLifeCycleEvent(
          source: LifePlatformSource.web,
          rawState: WebAppLifecycleState.windowFocus,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.browser),
        ),
        state,
      );
      expect(state.lastPhase, FlatLifecyclePhase.resumed);
    });

    test('macOS minimize maps to paused not separate hidden state', () {
      expect(
        FlatLifecycleMapper.resolve(
          const RawLifeCycleEvent(
            source: LifePlatformSource.macos,
            rawState: MacosAppLifecycleState.windowDidMiniaturize,
            extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.window),
          ),
          FlatLifecycleMapperState.empty,
        ),
        FlatLifecyclePhase.paused,
      );
    });
  });

  group('FlatLifecyclePhaseX', () {
    test('converts to AppLifecycleState', () {
      expect(
        FlatLifecyclePhase.resumed.toAppLifecycleState,
        AppLifecycleState.resumed,
      );
      expect(FlatLifecyclePhase.unknown.toAppLifecycleState, isNull);
    });
  });

  group('LifecycleStateStore', () {
    late RawLifeCycleManager manager;
    late LifecycleStateStore store;

    setUp(() {
      manager = RawLifeCycleManager.instance..resetForTesting();
      store = LifecycleStateStore.instance
        ..detach(manager)
        ..reset();
    });

    tearDown(() {
      store.detach(manager);
      store.reset();
      manager.resetForTesting();
    });

    test('tracks platform and flat snapshots', () async {
      RawLifeCycleManager.adapterFactoryOverride = (_) => _FakeAdapter();
      store.attach(manager);
      await manager.initialize();

      _FakeAdapter.lastInstance!.emit(
        const RawLifeCycleEvent(
          source: LifePlatformSource.ios,
          rawState: IosAppLifecycleState.applicationDidEnterBackground,
          extra: LifeCycleEventExtra(
            lifecycleScope: LifecycleScope.application,
          ),
        ),
      );

      expect(
        store.platform.rawState,
        IosAppLifecycleState.applicationDidEnterBackground,
      );
      expect(store.flat.phase, FlatLifecyclePhase.paused);
      expect(currentFlatLifecyclePhase, FlatLifecyclePhase.paused);
    });
  });

  group('FlatLifecycleMixin', () {
    test('invokes flat callbacks on phase change', () {
      final handler = _FlatHandler();

      handler.onPlatformLifecycleEvent(
        const RawLifeCycleEvent(
          source: LifePlatformSource.web,
          rawState: WebAppLifecycleState.visibilityChangeHidden,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.browser),
        ),
      );

      expect(handler.flatLifecyclePhase, FlatLifecyclePhase.paused);
      expect(handler.appLifecycleState, AppLifecycleState.paused);
      expect(handler.pausedCount, 1);
    });
  });

  group('PlatformLifecycleStateMixin', () {
    test('records latest native snapshot', () {
      final handler = _PlatformStateHandler();

      handler.onPlatformLifecycleEvent(
        const RawLifeCycleEvent(
          source: LifePlatformSource.android,
          rawState: AndroidAppLifecycleState.onPause,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.activity),
        ),
      );

      expect(handler.currentPlatformRawState, AndroidAppLifecycleState.onPause);
      expect(handler.currentPlatformLifecycleScope, LifecycleScope.activity);
    });
  });
}

final class _FlatHandler with LifecycleListenerBinding, FlatLifecycleMixin {
  var pausedCount = 0;

  @override
  void onFlatPaused(RawLifeCycleEvent event) {
    pausedCount++;
  }
}

final class _PlatformStateHandler
    with LifecycleListenerBinding, PlatformLifecycleStateMixin {}

final class _FakeAdapter implements LifeCycleAdapter {
  _FakeAdapter() {
    lastInstance = this;
  }

  static _FakeAdapter? lastInstance;

  LifeCycleEventCallback? _onEvent;

  @override
  LifePlatformSource get platformSource => LifePlatformSource.ios;

  @override
  Future<void> listen(LifeCycleEventCallback onEvent) async {
    _onEvent = onEvent;
  }

  @override
  Future<void> dispose() async {
    _onEvent = null;
  }

  void emit(RawLifeCycleEvent event) {
    _onEvent?.call(event);
  }
}
