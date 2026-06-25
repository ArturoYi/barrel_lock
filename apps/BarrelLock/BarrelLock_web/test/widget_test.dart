import 'package:barrel_lock_web/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows welcome message', (WidgetTester tester) async {
    await tester.pumpWidget(const BazaarApp());

    expect(find.text('Welcome to Flutter Bazaar'), findsOneWidget);
  });
}
