import 'package:fast_dialog/src/core/dialog_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final manager = DialogManager.instance;

  setUp(manager.resetForTest);

  tearDown(manager.resetForTest);

  group('DialogManager stack', () {
    test('show pushes entry and isShowing', () {
      manager.show(builder: (_) => const SizedBox());
      expect(manager.stack.length, 1);
      expect(manager.isShowing, isTrue);
    });

    test('dismiss pops top entry', () async {
      manager.show(builder: (_) => const SizedBox());
      manager.show(builder: (_) => const SizedBox());

      manager.dismiss();
      expect(manager.stack.length, 1);

      manager.dismiss();
      expect(manager.stack, isEmpty);
      expect(manager.isShowing, isFalse);
    });

    test('dismissAll clears stack', () {
      manager.show(builder: (_) => const SizedBox());
      manager.show(builder: (_) => const SizedBox());

      manager.dismissAll();
      expect(manager.stack, isEmpty);
    });

    test('same tag reuses entry instead of stacking', () {
      manager.show(tag: 'confirm', builder: (_) => const SizedBox());
      manager.show(
        tag: 'confirm',
        builder: (_) => const SizedBox(key: Key('b')),
      );

      expect(manager.stack.length, 1);
      expect(manager.stack.single.tag, 'confirm');
    });

    test('dismiss completes future with result', () async {
      final future = manager.show<bool>(builder: (_) => const SizedBox());
      manager.dismiss(result: true);
      expect(await future, isTrue);
    });

    test('dismissByRoute removes bound dialogs only', () {
      manager.bindRoute('home');
      manager.show(builder: (_) => const SizedBox());
      manager.show(builder: (_) => const SizedBox());

      manager.bindRoute('detail');
      manager.show(builder: (_) => const SizedBox());

      manager.dismissByRoute('home');
      expect(manager.stack.length, 1);
      expect(manager.stack.single.routeIdentity, 'detail');
    });
  });
}
