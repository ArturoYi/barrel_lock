import 'package:fast_dialog/fast_dialog.dart';
import 'package:fast_dialog/src/core/dialog_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final manager = DialogManager.instance;

  setUp(manager.resetForTest);

  tearDown(manager.resetForTest);

  testWidgets('FastDialogOverlay shows and dismisses dialog with animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return FastDialogOverlay(child: child ?? const SizedBox.shrink());
        },
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.pump();
    await tester.pump();

    var shown = false;
    var dismissed = false;

    FastDialog.show(
      builder: (context) => Container(
        width: 200,
        height: 100,
        color: Colors.white,
        alignment: Alignment.center,
        child: const Text('Hello Dialog'),
      ),
      showConfig: DialogShowConfig(
        animation: const DialogAnimationSpec(
          duration: Duration(milliseconds: 200),
        ),
        onShow: () => shown = true,
        onDismiss: () => dismissed = true,
      ),
    );

    await tester.pump();
    expect(FastDialog.isShowing, isTrue);
    expect(find.text('Hello Dialog'), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(shown, isTrue);

    FastDialog.dismiss();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(FastDialog.isShowing, isFalse);
    expect(find.text('Hello Dialog'), findsNothing);
    expect(dismissed, isTrue);
  });

  testWidgets('mask tap dismisses when maskDismissible', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return FastDialogOverlay(child: child ?? const SizedBox.shrink());
        },
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.pump();
    await tester.pump();

    FastDialog.show(
      builder: (context) => const SizedBox(width: 100, height: 100),
      showConfig: const DialogShowConfig(maskDismissible: true),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(FastDialog.isShowing, isFalse);
  });

  testWidgets('same tag refreshes without stacking', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return FastDialogOverlay(child: child ?? const SizedBox.shrink());
        },
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.pump();
    await tester.pump();

    FastDialog.show(tag: 'edit', builder: (context) => const Text('v1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    FastDialog.show(tag: 'edit', builder: (context) => const Text('v2'));
    await tester.pump();

    expect(find.text('v1'), findsNothing);
    expect(find.text('v2'), findsOneWidget);
    expect(DialogManager.instance.stack.length, 1);
  });
}
