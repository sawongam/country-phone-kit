import 'package:country_phone_kit/country_phone_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in the minimum a Material widget needs to be pumped.
Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  final nepal = Countries.byIsoCode('NP')!;
  final us = Countries.byIsoCode('US')!;

  group('PhoneNumberField', () {
    testWidgets('shows the country dial code and reports typed digits', (
      tester,
    ) async {
      var value = PhoneNumber(country: nepal);

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) => PhoneNumberField(
              value: value,
              label: 'Mobile',
              onChanged: (number) => setState(() => value = number),
            ),
          ),
        ),
      );

      expect(find.text('+977'), findsOneWidget);
      expect(find.text('Mobile'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '9812345678');
      await tester.pump();

      // The value holds bare digits even though the field shows them grouped.
      expect(value.nationalNumber, '9812345678');
      expect(value.e164, '+9779812345678');
      expect(value.isValid, isTrue);
    });

    testWidgets('strips the trunk 0 and separators a paste carries', (
      tester,
    ) async {
      var value = PhoneNumber(country: nepal);

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) => PhoneNumberField(
              value: value,
              onChanged: (number) => setState(() => value = number),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '0 (981) 234-5678');
      await tester.pump();

      expect(value.nationalNumber, '9812345678');
    });

    testWidgets('renders errorText from the caller', (tester) async {
      await tester.pumpWidget(
        _host(
          PhoneNumberField(
            value: PhoneNumber(country: nepal),
            errorText: 'Enter a phone number',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Enter a phone number'), findsOneWidget);
    });

    testWidgets('regroups the same digits when the country changes', (
      tester,
    ) async {
      Widget build(PhoneNumber value) =>
          _host(PhoneNumberField(value: value, onChanged: (_) {}));

      await tester.pumpWidget(
        build(PhoneNumber(country: us, nationalNumber: '2025550100')),
      );
      final asAmerican = tester
          .widget<TextField>(find.byType(TextField))
          .controller!
          .text;

      await tester.pumpWidget(
        build(PhoneNumber(country: nepal, nationalNumber: '2025550100')),
      );
      final asNepali = tester
          .widget<TextField>(find.byType(TextField))
          .controller!
          .text;

      expect(asAmerican, isNot(asNepali));
      expect(find.text('+977'), findsOneWidget);
    });

    testWidgets('a disabled field does not open the picker', (tester) async {
      await tester.pumpWidget(
        _host(
          PhoneNumberField(
            value: PhoneNumber(country: nepal),
            enabled: false,
            onChanged: (_) {},
          ),
        ),
      );

      // No hit target at all when disabled, which is the point.
      await tester.tap(find.text('+977'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Select country'), findsNothing);
    });

    testWidgets('tapping the selector opens the picker and applies the pick', (
      tester,
    ) async {
      var value = PhoneNumber(country: nepal, nationalNumber: '9812345678');

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) => PhoneNumberField(
              value: value,
              onChanged: (number) => setState(() => value = number),
            ),
          ),
        ),
      );

      await tester.tap(find.text('+977'));
      await tester.pumpAndSettle();
      expect(find.text('Select country'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'india');
      await tester.pumpAndSettle();
      await tester.tap(find.text('India'));
      await tester.pumpAndSettle();

      expect(value.country.isoCode, 'IN');
      // Switching country must not clear a number in progress.
      expect(value.nationalNumber, '9812345678');
    });
  });

  group('CountryPickerSheet', () {
    testWidgets('filters as the query is typed', (tester) async {
      await tester.pumpWidget(_host(CountryPickerSheet(onSelected: (_) {})));

      expect(find.text('Nepal'), findsNothing); // far down a 243-row list

      await tester.enterText(find.byType(TextField), 'nepal');
      await tester.pumpAndSettle();

      expect(find.text('Nepal'), findsOneWidget);
      expect(find.text('India'), findsNothing);
    });

    testWidgets('shows the empty state when nothing matches', (tester) async {
      await tester.pumpWidget(_host(CountryPickerSheet(onSelected: (_) {})));

      await tester.enterText(find.byType(TextField), 'qqqqqq');
      await tester.pumpAndSettle();

      expect(find.text('No match'), findsOneWidget);
    });

    testWidgets('takes its copy from CountryPickerLabels', (tester) async {
      await tester.pumpWidget(
        _host(
          CountryPickerSheet(
            onSelected: (_) {},
            labels: const CountryPickerLabels(
              searchHint: 'Rechercher',
              emptyTitle: 'Aucun résultat',
            ),
          ),
        ),
      );

      expect(find.text('Rechercher'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'qqqqqq');
      await tester.pumpAndSettle();

      expect(find.text('Aucun résultat'), findsOneWidget);
    });

    testWidgets('reports the country the user taps', (tester) async {
      Country? picked;

      await tester.pumpWidget(
        _host(CountryPickerSheet(onSelected: (country) => picked = country)),
      );

      await tester.enterText(find.byType(TextField), 'nepal');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nepal'));
      await tester.pump();

      expect(picked?.isoCode, 'NP');
    });
  });

  group('CurrencyPickerSheet', () {
    testWidgets('filters as the query is typed', (tester) async {
      await tester.pumpWidget(_host(CurrencyPickerSheet(onSelected: (_) {})));

      await tester.enterText(find.byType(TextField), 'nepalese');
      await tester.pumpAndSettle();

      expect(find.text('Nepalese rupee'), findsOneWidget);
      expect(find.text('NPR'), findsOneWidget);
      expect(find.text('Euro'), findsNothing);
    });

    testWidgets('lists a shared currency once', (tester) async {
      await tester.pumpWidget(_host(CurrencyPickerSheet(onSelected: (_) {})));

      await tester.enterText(find.byType(TextField), 'euro');
      await tester.pumpAndSettle();

      // 28 countries use it; the picker offers it once.
      expect(find.text('EUR'), findsOneWidget);
    });

    testWidgets('shows the empty state when nothing matches', (tester) async {
      await tester.pumpWidget(_host(CurrencyPickerSheet(onSelected: (_) {})));

      await tester.enterText(find.byType(TextField), 'qqqqqq');
      await tester.pumpAndSettle();

      expect(find.text('No match'), findsOneWidget);
    });

    testWidgets('takes its copy from CurrencyPickerLabels', (tester) async {
      await tester.pumpWidget(
        _host(
          CurrencyPickerSheet(
            onSelected: (_) {},
            labels: const CurrencyPickerLabels(searchHint: 'Rechercher'),
          ),
        ),
      );

      expect(find.text('Rechercher'), findsOneWidget);
    });

    testWidgets('reports the currency the user taps', (tester) async {
      CountryCurrency? picked;

      await tester.pumpWidget(
        _host(CurrencyPickerSheet(onSelected: (c) => picked = c)),
      );

      await tester.enterText(find.byType(TextField), 'nepalese');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nepalese rupee'));
      await tester.pump();

      expect(picked?.code, 'NPR');
    });

    testWidgets('marks the selected currency', (tester) async {
      await tester.pumpWidget(
        _host(
          CurrencyPickerSheet(
            selected: Currencies.byCode('NPR'),
            onSelected: (_) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'nepalese');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });

  group('showCurrencyPicker', () {
    testWidgets('opens a sheet and pops the pick', (tester) async {
      CountryCurrency? result;

      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showCurrencyPicker(context: context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Select currency'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'nepalese');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nepalese rupee'));
      await tester.pumpAndSettle();

      expect(result?.code, 'NPR');
      expect(find.text('Select currency'), findsNothing);
    });
  });

  group('PhoneNumberInputFormatter', () {
    test('groups digits the way the country writes them', () {
      expect(
        PhoneNumberInputFormatter.formatDigits('2025550100', 'US'),
        '(202) 555-0100',
      );
      expect(PhoneNumberInputFormatter.formatDigits('', 'US'), isEmpty);
    });

    test('keeps the caret after the digit the user just typed', () {
      final formatter = PhoneNumberInputFormatter('US');
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '202555',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );

      // Six digits typed, so the caret sits after the sixth digit wherever
      // grouping has moved it to.
      expect(result.text.replaceAll(RegExp(r'\D'), ''), '202555');
      expect(
        result.text
            .substring(0, result.selection.end)
            .replaceAll(RegExp(r'\D'), ''),
        hasLength(6),
      );
    });

    test('clearing the field clears the value', () {
      final formatter = PhoneNumberInputFormatter('US');
      expect(
        formatter.formatEditUpdate(
          const TextEditingValue(text: '(202) 555'),
          TextEditingValue.empty,
        ),
        TextEditingValue.empty,
      );
    });
  });

  group('CountryFlag', () {
    testWidgets('draws the emoji and hides it from screen readers', (
      tester,
    ) async {
      await tester.pumpWidget(_host(CountryFlag(nepal.flag)));

      expect(find.text('🇳🇵'), findsOneWidget);
      // Decorative next to the country name it always accompanies.
      expect(
        find.descendant(
          of: find.byType(CountryFlag),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });
  });

  group('CurrencyDropdownField', () {
    testWidgets('opens under the field and applies the tapped currency', (
      tester,
    ) async {
      CountryCurrency? picked;

      await tester.pumpWidget(
        _host(
          CurrencyDropdownField(
            label: 'Currency',
            value: Currencies.byCode('NPR'),
            onChanged: (currency) => picked = currency,
          ),
        ),
      );

      expect(find.text('Nepalese rupee (NPR)'), findsOneWidget);

      // The menu is not built until the field is tapped open.
      expect(find.byType(ListTile), findsNothing);

      await tester.tap(find.byType(CurrencyDropdownField));
      await tester.pumpAndSettle();

      // The list is virtualized, so filter to the row before tapping it —
      // "US dollar" sorts well past what an unfiltered list renders.
      await tester.enterText(find.byType(TextField).last, 'usd');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'United States dollar (USD)'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, 'United States dollar (USD)'));
      await tester.pumpAndSettle();

      expect(picked, Currencies.byCode('USD'));
      // Picking a row closes the menu.
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('filters the menu as the query is typed', (tester) async {
      await tester.pumpWidget(
        _host(
          CurrencyDropdownField(
            value: Currencies.byCode('NPR'),
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CurrencyDropdownField));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'euro');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'Euro (EUR)'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'United States dollar (USD)'), findsNothing);
    });

    testWidgets('tapping outside the menu closes it without a pick', (
      tester,
    ) async {
      CountryCurrency? picked;

      await tester.pumpWidget(
        _host(
          CurrencyDropdownField(
            value: Currencies.byCode('NPR'),
            onChanged: (currency) => picked = currency,
          ),
        ),
      );

      await tester.tap(find.byType(CurrencyDropdownField));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsWidgets);

      // Tap the barrier well away from the field and its menu.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNothing);
      expect(picked, isNull);
    });
  });
}
