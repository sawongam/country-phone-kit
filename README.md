# country_phone_kit

[![pub package](https://img.shields.io/pub/v/country_phone_kit.svg)](https://pub.dev/packages/country_phone_kit)
![Publisher](https://img.shields.io/badge/Publisher-sawongam-blue.svg)

<p align="center">
  <img src="docs/country.gif" width="320" alt="country_phone_kit demo" />
</p>

Every app that asks a user where they are from needs the same handful of
things, and they are scattered across packages that disagree with each other:

| You need | Here it is |
| --- | --- |
| The country list — names, flags, ISO codes | `Countries.all` |
| Dial codes, both directions | `country.dialCode`, `Countries.byDialCode('977')` |
| Validation *per country*, not a length check | `PhoneNumber.isValidNumber(input, isoCode: 'NP')` |
| Formatting — as you type, and for the wire | `PhoneNumberInputFormatter`, `number.e164` |
| Currencies — code, name, symbol, per country | `Currencies.all`, `country.currency` |

This package is all five in one, as plain Dart data you can read directly — and
then, **only if you want it**, a phone field, a country picker and a currency
picker built on top that inherit your `ThemeData`.

```dart
import 'package:country_phone_kit/country_phone_kit.dart';

Countries.all;                                          // 243 countries
Countries.byIsoCode('NP')!.flag;                        // 🇳🇵
Countries.byIsoCode('NP')!.dialCodePrefix;              // +977
PhoneNumber.isValidNumber('9812345678', isoCode: 'NP'); // true
PhoneNumber.formatE164('(981) 234-5678', isoCode: 'NP');// +9779812345678
Currencies.all;                                         // 153 currencies
Currencies.forCountry('NP');                            // NPR · Nepalese rupee · Rs
```

No network calls, no JSON to decode at startup, no assets to bundle. The
country table is one `const` list compiled into your binary. Validation and
grouping run on Google's libphonenumber metadata through
[`dlibphonenumber`](https://pub.dev/packages/dlibphonenumber), so a number of
the right length whose prefix no carrier issues is still rejected.

## Install

```yaml
dependencies:
  country_phone_kit: ^1.0.0
```

```dart
import 'package:country_phone_kit/country_phone_kit.dart';
```

One import gets you everything below. Use as much or as little as you like —
the data works without the widgets.

---

## 1. The country list

`Countries.all` is 243 countries sorted by English name, ready to hand to a
`ListView`, a `DropdownButton`, or your own design system.

```dart
for (final country in Countries.all) {
  print('${country.flag} ${country.name} (${country.isoCode}) ${country.dialCodePrefix}');
  // 🇳🇵 Nepal (NP) +977
}
```

Each `Country` carries:

| Field | Example | Notes |
| --- | --- | --- |
| `name` | `Nepal` | English, and the list's sort order |
| `isoCode` | `NP` | ISO-3166-1 alpha-2 — the identity; equality is by this |
| `iso3Code` | `NPL` | alpha-3; null for a few territories that have none |
| `dialCode` | `977` | **without** the `+` |
| `dialCodePrefix` | `+977` | with the `+`, for display |
| `flag` | `🇳🇵` | regional-indicator emoji — scales, themes, costs nothing to bundle |
| `minLength` / `maxLength` | `10` / `10` | national-number digits; for sizing a field, *not* for validating |
| `currency` | `NPR · Nepalese rupee · Rs` | ISO-4217 code, name, symbol |

### Lookups

```dart
Countries.byIsoCode('np');            // Country? — case-insensitive, null-tolerant
Countries.byDialCode('977');          // List<Country> — every country on +977
Countries.byDialCode('1');            // US, Canada, Dominican Republic
Countries.primaryForDialCode('1');    // United States — when you need exactly one
Countries.longestDialCodePrefix('9779812345678');  // '977', never '97'
Countries.search('nep');              // ranked for a picker: exact → starts-with → contains
```

`search` ranks an exact ISO or dial-code hit first, then names that *start* with
the query, then names that merely contain it — so typing `in` puts India above
Finland without any scoring to tune. It runs over a `const` list in memory, so
you can call it on every keystroke without a debounce.

## 2. A phone number

`PhoneNumber` keeps the country and the national number apart, which is the
whole point — a single `String` field forces every consumer to re-guess where
the dial code ends, and they guess differently. That is how the same user ends
up stored as `+9779…` on one screen and `09779…` on another.

```dart
final nepal = Countries.byIsoCode('NP')!;
final number = PhoneNumber.parse('+977 098-1234-5678', fallbackCountry: nepal);

number.country.isoCode;     // 'NP'
number.nationalNumber;      // '9812345678'  — separators and trunk 0 gone
number.dialCode;            // '977'
number.e164;                // '+9779812345678'   ← what you send
number.isValid;             // true
number.error;               // null, or empty / tooShort / tooLong / invalid
number.formatNational;      // '981-2345678'
number.formatInternational; // '+977 981-2345678' ← what you show
```

`parse` never throws and never refuses: a half-typed number has to survive the
trip. It reads a leading `+` or `00` as international and matches the dial code
longest-first; anything else is a national number in `fallbackCountry`.

## 3. Validation, per country

Two forms. The one-liner, when you just need a yes or no:

```dart
PhoneNumber.isValidNumber('9812345678', isoCode: 'NP');   // true
PhoneNumber.isValidNumber('+977 981 234 5678');           // true — code says the country
PhoneNumber.formatE164('981 234 5678', isoCode: 'NP');    // '+9779812345678', or null if invalid
```

Or the model, when you want to tell the user *what* is wrong:

```dart
switch (number.error) {
  case PhoneNumberError.empty:    return 'Enter a phone number';
  case PhoneNumberError.tooShort: return 'That number is too short';
  case PhoneNumberError.tooLong:  return 'That number is too long';
  case PhoneNumberError.invalid:  return 'Not a valid number for ${number.country.name}';
  case null:                      return null;
}
```

This is a metadata verdict, not a digit count:

```dart
PhoneNumber.isValidNumber('1112223333', isoCode: 'NP');  // false
// Ten digits — exactly Nepal's length — but no carrier issues that prefix.
// A minLength/maxLength check would wave it through.
```

> **While a number is being typed** the verdict moves `tooShort` → `invalid` →
> valid. That middle step is not a bug: Nepal has eight-digit landlines and
> ten-digit mobiles, so nine digits is a length the country simply does not use.
> A form that validates on every keystroke should show one message for anything
> non-null rather than narrating the transition; the distinction is there for a
> form that validates on submit.

It is still not a claim that the number is *in service*. libphonenumber knows
which prefixes a country issues, not which ones are connected. Whether someone
answers is your backend's verdict.

## 4. Formatting as the user types

`PhoneNumberInputFormatter` groups digits the way each country writes them —
`(202) 555-0100` in the US, `981-2345678` in Nepal, `98123 45678` in India —
and works on any `TextField`, not just this package's:

```dart
TextField(
  keyboardType: TextInputType.phone,
  inputFormatters: [PhoneNumberInputFormatter('NP')],
)
```

The caret is tracked by *digit position*, so editing mid-number does not throw
it to the end on every keystroke. The grouping is display only — everything
downstream reads bare digits.

```dart
PhoneNumberInputFormatter.formatDigits('2025550100', 'US');  // '(202) 555-0100'
```

## 5. Currencies

The same table read the other way. Every country carries the currency it
transacts in, and `Currencies` is that data indexed by ISO-4217 code —
deduplicated, so the euro appears once rather than twenty-eight times.

```dart
Currencies.all;                       // 153 currencies, sorted by code
Currencies.byCode('npr');             // CountryCurrency? — case-insensitive
Currencies.forCountry('NP');          // what Nepal spends
Currencies.countriesUsing('EUR');     // the 28 countries back again
Currencies.search('rupee');           // ranked for a picker: INR, LKR, MUR, NPR, …
```

Each `CountryCurrency` is `code` (`NPR`), `name` (`Nepalese rupee`) and
`symbol` (`Rs`). Symbols are not unique — 24 currencies use `$` and 8 use `£` —
so show the code alongside the symbol wherever the country is not already
obvious from context.

Reached from a country directly, too:

```dart
final currency = Countries.byIsoCode('DE')!.currency!;
'${currency.symbol} ${currency.code}';  // '€ EUR'
```

`currency` is null only for Antarctica, which has none.

> **The currency data is corrected where the upstream source had gone stale.**
> Seven countries still carried the national currency they used before joining
> the euro — Cyprus, Malta, Slovakia, Estonia, Latvia, Lithuania, Croatia — two
> of them with `€` against the retired code, so a picker built on that source
> offers three different currencies all symbolised `€`. Nine more carried an
> ISO-4217 code that had been redenominated away (`GHC`→`GHS`, `SDD`→`SDG`,
> `TMM`→`TMT`, `ZMK`→`ZMW`, `MRO`→`MRU`, `STD`→`STN`, `VEF`→`VES`, `SLL`→`SLE`,
> `ZWD`→`ZWG`), which is worse than cosmetic: it hands your backend a code no
> payment processor will accept. Zimbabwe is the volatile one — if you settle it
> in USD, override that row. The fixes live in the generator's override table
> and are covered by tests, so a regeneration cannot quietly undo them.

---

## The optional UI

Everything above is data. If you also want the widgets, each is one call.

### PhoneNumberField

```dart
PhoneNumberField(
  value: _phone,
  label: 'Phone number',
  hintText: 'Enter your number',
  errorText: _errorFor(_phone),
  onChanged: (number) => setState(() => _phone = number),
)
```

Controlled: it renders the `PhoneNumber` you give it and reports every change
back, holding no phone state of its own. That is what keeps the country and the
digits from drifting apart. Tapping the flag opens the country picker; digits
group as they are typed; `onChanged` always hands back clean digits.

Also takes `enabled`, `required`, `autofocus`, `focusNode`, `textInputAction`,
`onSubmitted`, `pickerLabels`, `useRootNavigator` and a full `decoration`
override.

### The country picker

Use it on its own — with the field, or with nothing at all:

```dart
final picked = await showCountryPicker(context: context, selected: current);
```

It opens as a draggable bottom sheet, scrolled to the current selection, with
search over name, both ISO codes and dial code. For a settings page or a
wide-layout side panel, embed `CountryPickerSheet` directly without the sheet
chrome. `CountryListTile` and `CountryFlag` are exported too, if you would
rather build the list yourself and only borrow the rows.

### The currency picker

Same shape, same chrome, same search behaviour:

```dart
final picked = await showCurrencyPicker(
  context: context,
  selected: Currencies.byCode('NPR'),
);
```

Search covers the code, the name and the symbol, so `usd`, `dollar` and `$` all
find something, and an exact code hit ranks first. Embed `CurrencyPickerSheet`
for an inline panel, or borrow `CurrencyListTile` for a list of your own — the
symbol sits in a fixed-width slot so names line up down the list.

### Styling

All three widgets read `Theme.of(context)` throughout — `colorScheme`, `textTheme`,
`InputDecorationTheme`. There are no hard-coded colours, radii or spacing, so
they pick up your app's look with no configuration. For full control over the
field:

```dart
PhoneNumberField(
  value: _phone,
  onChanged: _onChanged,
  decoration: InputDecoration(border: OutlineInputBorder(), filled: true),
)
```

### Localisation

The package owns no ARB file. Pass your own strings:

```dart
PhoneNumberField(
  // ...
  pickerLabels: CountryPickerLabels(
    title: context.l10n.selectCountry,
    searchHint: context.l10n.searchCountryOrCode,
    clearSearchTooltip: context.l10n.clearSearch,
    emptyTitle: context.l10n.noMatch,
    emptyMessage: context.l10n.noCountryMatches,
  ),
)
```

`CurrencyPickerLabels` does the same for the currency picker. The English
defaults exist so a widget test can open a picker — not so strings can skip
your translators. Error copy is yours the same way: map
`PhoneNumberError` at the call site.

## Example app

```sh
cd example
flutter pub get
flutter run
```

A gallery of the lot: the raw data with no widgets involved, the field with
live validation and an E.164 readout, the country picker, the currency picker
(with the countries that use what you picked), and `PhoneNumber.parse` — plus a
theme toggle so you can watch the widgets pick up light and dark `ThemeData`.

## What this package deliberately does not do

- **No state.** The current `PhoneNumber` lives in your state, not in a widget.
- **No default country.** Pass your own fallback; a wrong guess is worse than
  a question.
- **No design system dependency.** Every colour, space and radius comes from
  the ambient `Theme`.
- **No claim a number is reachable.** Only your backend can say that.

## Design and cost

The country table is generated, not fetched. Nothing is decoded at startup.

Measured on AOT-compiled Dart:

| Operation | Cost |
| --- | --- |
| `Countries.search` — one keystroke in the picker | 24 µs |
| `PhoneNumber.parse` | 1.6 µs |
| `PhoneNumber.error` — one libphonenumber verdict | 197 µs |
| `formatNational` / input-formatter grouping | ~140–195 µs |
| First validation per country (metadata load) | 5,000 µs, once |
| Binary size added by `dlibphonenumber` | ~2.9 MB |

A keystroke in the phone field costs roughly 0.5 ms — about 3% of a frame. The
5 ms metadata load on the *first* validation for a country lands on whichever
keystroke comes first; if that shows up as a hitch, validate a throwaway number
when the page mounts to move it off the typing path.

## Contributing

`lib/src/data/country_data.dart` is generated. Do not edit it.

```sh
dart run tool/generate_countries.dart
dart format . && dart analyze --fatal-infos && flutter test
```

The two inputs live in `tool/source/`:

| File | Holds |
| --- | --- |
| `countries_source.dart` | Name, flag emoji, alpha-2 code, dial code, number lengths |
| `currency_source.dart` | Alpha-3 code, currency code / name / symbol |

The generator is strict on purpose: an unmatched row fails the run rather than
emitting a country that is quietly missing half its data.

Issues and pull requests:
<https://github.com/sawongam/country-phone-kit/issues>

## License

MIT — see [LICENSE](LICENSE).
