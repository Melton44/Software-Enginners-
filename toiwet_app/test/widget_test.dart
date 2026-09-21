import 'package:flutter_test/flutter_test.dart';
import 'package:toiwet_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ToiwetApp());
    expect(find.text('Toiwet Member Profile'), findsOneWidget);
  });
}