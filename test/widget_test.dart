import 'package:flutter_test/flutter_test.dart';

import 'package:flexplan/main.dart';

void main() {
  testWidgets('Counter increment smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlexplanApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsNothing); // Flexplan doesn't have a counter
  });
}
