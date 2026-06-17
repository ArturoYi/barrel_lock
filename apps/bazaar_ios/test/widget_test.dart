import 'package:bazaar_ios/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows welcome message', (WidgetTester tester) async {
    await tester.pumpWidget(const BazaarApp());

    expect(find.text('Welcome to Flutter Bazaar'), findsOneWidget);
  });
}
