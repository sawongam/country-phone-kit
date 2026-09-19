# country_phone_kit example

A gallery for the package:

| Card | Shows |
| --- | --- |
| **Type a number** | `PhoneNumberField` with live validation, as-you-type grouping and an E.164 readout |
| **Pick a country** | `showCountryPicker`, plus the dial code, digit lengths and currency of what you picked |
| **Pick a currency** | `showCurrencyPicker`, plus `Currencies.countriesUsing` — the flags of every country that spends what you picked |
| **Pick a currency inline** | `CurrencyDropdownField` — the same currencies as an inline searchable dropdown, no sheet |
| **Paste any format** | `PhoneNumber.parse` against `+977 …`, `00 44 …` and `(202) 555-0100` |

Styling comes entirely from `ThemeData` — the toggle in the app bar flips
light and dark so you can watch the widgets follow along.

## Run

From this directory:

```sh
flutter pub get
flutter run
```

Linux, macOS, Windows, Chrome and attached devices all work:

```sh
flutter run -d chrome
```

If you got this from pub.dev rather than from the repository, the per-platform
folders are not in the archive — run `flutter create .` here first to put them
back.
