/// Country reference data, per-country phone validation and formatting, and
/// the optional widgets built on them.
///
/// One `const` table backs everything here: name, flag emoji, ISO alpha-2 and
/// alpha-3 codes, dial code, national-number lengths and currency, merged at
/// build time from the two sources in `tool/`. Nothing is decoded at runtime
/// and nothing is fetched.
///
/// ```dart
/// Countries.all;                                          // 243 countries
/// Countries.byIsoCode('NP')!.flag;                        // 🇳🇵
/// Countries.byIsoCode('NP')!.dialCodePrefix;              // +977
/// Countries.byIsoCode('NP')!.currency!.symbol;            // Rs
/// Currencies.all;                                         // 153 currencies
/// PhoneNumber.isValidNumber('9812345678', isoCode: 'NP'); // true
/// ```
///
/// ## Where to start
///
/// The data, which needs no widgets:
///
/// - [Countries] — the table, plus lookup by ISO code, lookup by dial code and
///   the ranked search a picker wants.
/// - [Country] — one row: name, flag, both ISO codes, dial code, number
///   lengths, [CountryCurrency].
/// - [Currencies] — the same data indexed the other way: every ISO-4217
///   currency once, with the countries that use it.
/// - [PhoneNumber] — a country and a national number held apart, with parsing,
///   E.164 output and validation. [PhoneNumber.isValidNumber] and
///   [PhoneNumber.formatE164] are the one-line forms.
/// - [PhoneNumberInputFormatter] — as-you-type digit grouping for any
///   `TextField`.
///
/// The UI, if you want it:
///
/// - [PhoneNumberField] — country selector plus number field, grouping digits
///   as they are typed.
/// - [showCountryPicker] — the searchable country sheet, on its own.
/// - [showCurrencyPicker] — the same, for currencies.
/// - [CurrencyDropdownField] — currency entry as an inline searchable
///   dropdown, for a form that would rather not open a sheet.
/// - [SearchableDropdownField] — the same inline-dropdown mechanism, generic
///   over any typed list, for building a dropdown [CurrencyDropdownField]
///   does not cover.
/// - [CountryPickerSheet], [CurrencyPickerSheet], [CountryListTile],
///   [CurrencyListTile], [CountryFlag] — the pieces, for a picker of your own
///   design.
///
/// ## What this package does not do
///
/// It owns no ARB file and no state. Copy comes in through
/// [CountryPickerLabels] and [CurrencyPickerLabels]; the current [PhoneNumber]
/// lives in the caller's state. Validation and display grouping come from Google's libphonenumber
/// metadata (`dlibphonenumber`), so a number of the right length with a prefix
/// no carrier issues is still rejected — but whether the number is *in service*
/// is the backend's verdict, and only the backend's.
library;

export 'src/countries.dart';
export 'src/currencies.dart';
export 'src/models/country.dart';
export 'src/models/country_currency.dart';
export 'src/phone_number.dart';
export 'src/phone_number_input_formatter.dart';
export 'src/widgets/country_flag.dart';
export 'src/widgets/country_list_tile.dart';
export 'src/widgets/country_picker_labels.dart';
export 'src/widgets/country_picker_sheet.dart';
export 'src/widgets/currency_dropdown_field.dart';
export 'src/widgets/currency_list_tile.dart';
export 'src/widgets/currency_picker_labels.dart';
export 'src/widgets/currency_picker_sheet.dart';
export 'src/widgets/phone_number_field.dart';
export 'src/widgets/searchable_dropdown_field.dart';
