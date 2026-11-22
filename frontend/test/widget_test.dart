import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Spendly app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SpendlyApp());
    expect(find.byType(SpendlyApp), findsOneWidget);
  });
}
