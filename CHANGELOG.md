## 1.0.0

First release.

### Data

- `Countries.all` — 243 countries as one `const` list, sorted by English name:
  name, flag emoji, ISO alpha-2 and alpha-3, dial code, national-number
  lengths and ISO-4217 currency.
- Lookups: `Countries.byIsoCode`, `byDialCode`, `primaryForDialCode`,
  `longestDialCodePrefix`, and a ranked `search` for pickers.
- The table is generated from the two sources in `tool/source/` by
  `dart run tool/generate_countries.dart`; nothing is decoded or fetched at
  runtime.

### Currencies

- `Currencies.all` — every ISO-4217 currency the country table names, once,
  sorted by code; `byCode`, `forCountry`, `countriesUsing` and a ranked
  `search` over code, name and symbol.
- `CountryCurrency` on every `Country`, null only for Antarctica.
- Sixteen rows had gone stale upstream and are corrected in the generator's
  override table, with tests so a regeneration cannot undo them:
  - Cyprus, Malta, Slovakia, Estonia, Latvia, Lithuania and Croatia carried the
    national currency each used before joining the euro.
  - Ghana, Sudan, Turkmenistan, Zambia, Mauritania, São Tomé and Príncipe,
    Venezuela, Sierra Leone and Zimbabwe carried an ISO-4217 code that had been
    redenominated away (`GHC`→`GHS`, `SDD`→`SDG`, `TMM`→`TMT`, `ZMK`→`ZMW`,
    `MRO`→`MRU`, `STD`→`STN`, `VEF`→`VES`, `SLL`→`SLE`, `ZWD`→`ZWG`).
- Five currencies whose name upstream was a bare noun — `Dollar`, `Franc`,
  `Peso` — now say which one they are.

### Phone numbers

- `PhoneNumber` — country and national number held apart, with `parse`, `e164`,
  `formatNational`, `formatInternational`, `isValid` and `error`.
- Validation and grouping run on Google's libphonenumber metadata via
  `dlibphonenumber`, so a number of the right length with a prefix no carrier
  issues is rejected.
- `PhoneNumber.isValidNumber` and `PhoneNumber.formatE164` for one-line checks
  that do not need the model.
- `PhoneNumberInputFormatter` — as-you-type grouping with caret tracking by
  digit position, usable on any `TextField`.

### Widgets

- `PhoneNumberField` — controlled phone input with a country selector.
- `showCountryPicker` and `CountryPickerSheet` — searchable country picker as a
  modal sheet or embedded inline.
- `showCurrencyPicker` and `CurrencyPickerSheet` — the same picker over
  currencies, searchable by code, name or symbol.
- `CurrencyDropdownField` — currency entry as an inline searchable dropdown
  anchored under the field, for forms that would rather not open a sheet.
- `SearchableDropdownField<T>` — the same inline dropdown, generic over any
  typed list.
- `CountryFlag`, `CountryListTile`, `CurrencyListTile`, `CountryPickerLabels`,
  `CurrencyPickerLabels`.
- Everything is styled through the ambient `ThemeData`; the package hard-codes
  no colours and ships no strings that cannot be replaced.
