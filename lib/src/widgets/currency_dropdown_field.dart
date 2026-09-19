import 'package:country_phone_kit/src/currencies.dart';
import 'package:country_phone_kit/src/models/country_currency.dart';
import 'package:country_phone_kit/src/widgets/currency_picker_labels.dart';
import 'package:country_phone_kit/src/widgets/searchable_dropdown_field.dart';
import 'package:flutter/material.dart';

/// Currency entry as an inline, searchable dropdown field.
///
/// Where [showCurrencyPicker] opens a full-height sheet, this stays on the
/// page: tapping it opens a short searchable menu anchored right under the
/// field, sized to the field's own width. Reach for this in a settings or
/// onboarding form where a sheet takeover would be heavier than the choice
/// deserves; reach for the sheet when the list benefits from the extra room a
/// sheet gives it.
///
/// Controlled, like [PhoneNumberField] and [SearchableDropdownField]: it
/// renders [value] and reports every change through [onChanged], holding no
/// currency state of its own.
///
/// ```dart
/// CurrencyDropdownField(
///   label: 'Currency',
///   required: true,
///   value: Currencies.byCode(state.currency.code),
///   onChanged: (currency) => cubit.currencyChanged(currency),
/// )
/// ```
class CurrencyDropdownField extends StatelessWidget {
  /// Builds a currency dropdown showing [value].
  const CurrencyDropdownField({
    required this.value,
    required this.onChanged,
    this.label,
    this.hintText,
    this.errorText,
    this.required = false,
    this.enabled = true,
    this.labels = const CurrencyPickerLabels(),
    this.decoration,
    super.key,
  });

  /// The currency currently in effect, or null if none is chosen yet.
  final CountryCurrency? value;

  /// Called with the currency the user picked.
  final ValueChanged<CountryCurrency> onChanged;

  /// Label above the field. Forwarded to [InputDecoration.label].
  final String? label;

  /// Placeholder shown when [value] is null.
  final String? hintText;

  /// Validation message under the field.
  final String? errorText;

  /// When true, an asterisk is appended to [label].
  final bool required;

  /// Whether the field opens the menu when tapped.
  final bool enabled;

  /// Localised copy, shared with [showCurrencyPicker] so the two controls read
  /// the same way wherever an app uses both.
  final CurrencyPickerLabels labels;

  /// Override the entire [InputDecoration] on the closed field.
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return SearchableDropdownField<CountryCurrency>(
      value: value,
      items: Currencies.all,
      itemLabel: (currency) => '${currency.name} (${currency.code})',
      itemMatchesSearch: (currency, query) => currency.matchesQuery(query),
      onChanged: onChanged,
      label: label,
      hintText: hintText,
      errorText: errorText,
      required: required,
      enabled: enabled,
      searchHint: labels.searchHint,
      clearSearchTooltip: labels.clearSearchTooltip,
      emptySearchMessage: labels.emptyMessage,
      decoration: decoration,
    );
  }
}
