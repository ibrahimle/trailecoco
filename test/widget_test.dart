import 'package:flutter_test/flutter_test.dart';
import 'package:eco_trail/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoTrailApp());
    expect(find.byType(EcoTrailApp), findsOneWidget);
  });
}

