import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gallery loads', (tester) async {
    await tester.pumpWidget(const CountryPhoneKitExampleApp());
    expect(find.text('country_phone_kit'), findsWidgets);
    expect(find.text('Type a number'), findsOneWidget);
    expect(find.text('Pick a country'), findsOneWidget);
    expect(find.text('Pick a currency'), findsOneWidget);
    expect(find.text('Pick a currency inline'), findsOneWidget);
    expect(find.text('Paste any format'), findsOneWidget);
  });
}
