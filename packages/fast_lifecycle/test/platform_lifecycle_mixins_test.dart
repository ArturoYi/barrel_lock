import 'package:fast_lifecycle/fast_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RawLifeCycleManager manager;

  setUp(() {
    manager = RawLifeCycleManager.instance..resetForTesting();
  });

  tearDown(() {
    manager.resetForTesting();
  });

  group('IosAppLifecycleMixin', () {
    test('dispatches application delegate callbacks', () {
      final handler = _IosHandler();

      handler.onPlatformLifecycleEvent(
        const RawLifeCycleEvent(
          source: LifePlatformSource.ios,
          rawState: IosAppLifecycleState.applicationDidEnterBackground,
          extra: LifeCycleEventExtra(
            lifecycleScope: LifecycleScope.application,
          ),
        ),
      );

      expect(handler.enteredBackground, isTrue);
    });
  });

  group('AndroidAppLifecycleMixin', () {
    test('dispatches process and activity separately', () {
      final handler = _AndroidHandler();

      handler.onPlatformLifecycleEvent(
        const RawLifeCycleEvent(
          source: LifePlatformSource.android,
          rawState: AndroidAppLifecycleState.onPause,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.process),
        ),
      );
      handler.onPlatformLifecycleEvent(
        const RawLifeCycleEvent(
          source: LifePlatformSource.android,
          rawState: AndroidAppLifecycleState.onPause,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.activity),
        ),
      );

      expect(handler.processPaused, isTrue);
      expect(handler.activityPaused, isTrue);
    });
  });

  group('MacosAppLifecycleMixin', () {
    test('dispatches window and application events', () {
      final handler = _MacosHandler();

      handler.onPlatformLifecycleEvent(
        const RawLifeCycleEvent(
          source: LifePlatformSource.macos,
          rawState: MacosAppLifecycleState.windowDidBecomeKey,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.window),
        ),
      );
      handler.onPlatformLifecycleEvent(
        const RawLifeCycleEvent(
          source: LifePlatformSource.macos,
          rawState: MacosAppLifecycleState.applicationDidHide,
          extra: LifeCycleEventExtra(
            lifecycleScope: LifecycleScope.application,
          ),
        ),
      );

      expect(handler.windowBecameKey, isTrue);
      expect(handler.appHidden, isTrue);
    });
  });

  group('multi platform mixin chain', () {
    test('Ios mixin passes unmatched events to super', () {
      final handler = _MultiPlatformHandler();

      handler.onPlatformLifecycleEvent(
        const RawLifeCycleEvent(
          source: LifePlatformSource.android,
          rawState: AndroidAppLifecycleState.onStop,
          extra: LifeCycleEventExtra(lifecycleScope: LifecycleScope.process),
        ),
      );

      expect(handler.processStopped, isTrue);
      expect(handler.iosBackground, isFalse);
    });
  });
}

final class _IosHandler with LifecycleListenerBinding, IosAppLifecycleMixin {
  var enteredBackground = false;

  @override
  void onApplicationDidEnterBackground(RawLifeCycleEvent event) {
    enteredBackground = true;
  }
}

final class _AndroidHandler
    with LifecycleListenerBinding, AndroidAppLifecycleMixin {
  var processPaused = false;
  var activityPaused = false;

  @override
  void onProcessPause(RawLifeCycleEvent event) {
    processPaused = true;
  }

  @override
  void onActivityPause(RawLifeCycleEvent event) {
    activityPaused = true;
  }
}

final class _MacosHandler
    with LifecycleListenerBinding, MacosAppLifecycleMixin {
  var windowBecameKey = false;
  var appHidden = false;

  @override
  void onWindowDidBecomeKey(RawLifeCycleEvent event) {
    windowBecameKey = true;
  }

  @override
  void onApplicationDidHide(RawLifeCycleEvent event) {
    appHidden = true;
  }
}

final class _MultiPlatformHandler
    with
        LifecycleListenerBinding,
        IosAppLifecycleMixin,
        AndroidAppLifecycleMixin {
  var iosBackground = false;
  var processStopped = false;

  @override
  void onApplicationDidEnterBackground(RawLifeCycleEvent event) {
    iosBackground = true;
  }

  @override
  void onProcessStop(RawLifeCycleEvent event) {
    processStopped = true;
  }
}
