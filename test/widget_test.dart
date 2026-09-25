import 'package:flutter_test/flutter_test.dart';
import 'package:karaoki/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const KaraokiApp());
    // Let the splash's animations run; it never settles (infinite repeat),
    // so pump a fixed duration instead of pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('KARAOKI'), findsOneWidget);

    // Advance past the splash's 1.2s auto-advance Timer so no timers are
    // left pending when the test tears down.
    await tester.pump(const Duration(milliseconds: 1300));
  });
}
