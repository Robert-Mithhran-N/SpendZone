import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_zone/app.dart';

void main() {
  testWidgets('SpendZone app launches', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SpendZoneApp(),
      ),
    );
    // Verify splash screen renders SpendZone title
    expect(find.text('SpendZone'), findsOneWidget);
    
    // Advance timers discrete steps to go past splash delay
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 1500));
  });
}
