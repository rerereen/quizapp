import 'package:flutter_test/flutter_test.dart';
import 'package:quizapp/main.dart';

void main() {
  testWidgets('App shows the Villasis history entry point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('HISTORY OF VILLASIS'), findsOneWidget);
    expect(find.text('START HISTORY'), findsOneWidget);
  });
}
