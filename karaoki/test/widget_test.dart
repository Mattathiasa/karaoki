import 'package:flutter_test/flutter_test.dart';
import 'package:karaoki/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const KaraokiApp());
    expect(find.text('KARAOKI'), findsOneWidget);
  });
}
