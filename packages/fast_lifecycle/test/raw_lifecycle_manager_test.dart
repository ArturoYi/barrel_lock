import 'package:flutter_test/flutter_test.dart';
import 'package:fast_lifecycle/fast_lifecycle.dart';

void main() {
  group('RawLifeCycleEvent', () {
    test('fromPlatformMap preserves rawState without mapping', () {
      final event = RawLifeCycleEvent.fromPlatformMap({
        'rawState': 'NSWindowDidBecomeKeyNotification',
        'extra': {
          'windowId': 'win-1',
          'isMainWindow': false,
          'lifecycleScope': 'window',
        },
      }, source: LifePlatformSource.macos);

      expect(event.rawState, 'NSWindowDidBecomeKeyNotification');
      expect(event.source, LifePlatformSource.macos);
      expect(event.extra.windowId, 'win-1');
      expect(event.extra.isMainWindow, isFalse);
      expect(event.extra.lifecycleScope, 'window');
    });

    test('fromPlatformMap parses Android process lifecycle', () {
      final event = RawLifeCycleEvent.fromPlatformMap({
        'rawState': 'ON_PAUSE',
        'extra': {'lifecycleScope': 'process'},
      }, source: LifePlatformSource.android);

      expect(event.rawState, 'ON_PAUSE');
      expect(event.extra.lifecycleScope, 'process');
    });

    test('fromPlatformMap parses iOS application delegate callback', () {
      final event = RawLifeCycleEvent.fromPlatformMap({
        'rawState': 'applicationDidEnterBackground',
        'extra': {'lifecycleScope': 'application'},
      }, source: LifePlatformSource.ios);

      expect(event.rawState, 'applicationDidEnterBackground');
      expect(event.extra.lifecycleScope, 'application');
    });

    test('fromPlatformMap rejects empty rawState', () {
      expect(
        () => RawLifeCycleEvent.fromPlatformMap({
          'rawState': '',
        }, source: LifePlatformSource.android),
        throwsFormatException,
      );
    });
  });

  group('LifecycleChannelNames', () {
    test('eventChannelForWindow isolates multi-window channels', () {
      expect(
        LifecycleChannelNames.eventChannelForWindow('main'),
        'fast_lifecycle/events/main',
      );
    });
  });

  group('RawLifeCycleManager', () {
    late RawLifeCycleManager manager;

    setUp(() {
      manager = RawLifeCycleManager.instance..resetForTesting();
    });

    tearDown(() {
      manager.resetForTesting();
    });

    test('dispatches events to registered listeners', () async {
      RawLifeCycleManager.adapterFactoryOverride = (_) => _FakeAdapter();

      final received = <RawLifeCycleEvent>[];
      manager.addListener(received.add);

      await manager.initialize();
      _FakeAdapter.lastInstance!.emit(
        const RawLifeCycleEvent(
          source: LifePlatformSource.ios,
          rawState: 'applicationDidEnterBackground',
          extra: LifeCycleEventExtra(lifecycleScope: 'application'),
        ),
      );

      expect(received, hasLength(1));
      expect(received.single.rawState, 'applicationDidEnterBackground');
      expect(received.single.extra.lifecycleScope, 'application');
    });

    test('initialize is idempotent', () async {
      var createCount = 0;
      RawLifeCycleManager.adapterFactoryOverride = (_) {
        createCount++;
        return _FakeAdapter();
      };

      await manager.initialize();
      await manager.initialize();

      expect(createCount, 1);
      expect(manager.isInitialized, isTrue);
    });

    test('dispose releases adapter', () async {
      RawLifeCycleManager.adapterFactoryOverride = (_) => _FakeAdapter();

      await manager.initialize();
      await manager.dispose();

      expect(_FakeAdapter.lastInstance!.disposed, isTrue);
      expect(manager.isInitialized, isFalse);
    });
  });
}

final class _FakeAdapter implements LifeCycleAdapter {
  _FakeAdapter() {
    lastInstance = this;
  }

  static _FakeAdapter? lastInstance;

  LifeCycleEventCallback? _onEvent;
  var disposed = false;

  @override
  LifePlatformSource get platformSource => LifePlatformSource.android;

  @override
  Future<void> listen(LifeCycleEventCallback onEvent) async {
    _onEvent = onEvent;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    _onEvent = null;
  }

  void emit(RawLifeCycleEvent event) {
    _onEvent?.call(event);
  }
}
