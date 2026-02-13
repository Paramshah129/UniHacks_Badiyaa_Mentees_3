import 'package:flutter_test/flutter_test.dart';
import 'package:friendsconnect/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const BondBoxApp());

    expect(find.byType(BondBoxApp), findsOneWidget);
  });
}