import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_phone_kit/country_phone_kit.dart';

void main() => runApp(const CountryPhoneKitExampleApp());

/// Seed is pine, not the Material default purple, so the widgets' Theme
/// pickup is obvious when you flip light and dark.
const _seed = Color(0xFF1F4E46);

class CountryPhoneKitExampleApp extends StatefulWidget {
  const CountryPhoneKitExampleApp({super.key});

  @override
  State<CountryPhoneKitExampleApp> createState() =>
      _CountryPhoneKitExampleAppState();
}

class _CountryPhoneKitExampleAppState extends State<CountryPhoneKitExampleApp> {
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'country_phone_kit',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: GalleryPage(
        themeMode: _mode,
        onThemeMode: (mode) => setState(() => _mode = mode),
      ),
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  const radius = BorderRadius.all(Radius.circular(8));

  OutlineInputBorder outline({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: color ?? scheme.outlineVariant,
        width: width,
      ),
    );
  }

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      isDense: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: outline(),
      enabledBorder: outline(),
      focusedBorder: outline(color: scheme.primary, width: 1.5),
      errorBorder: outline(color: scheme.error),
      focusedErrorBorder: outline(color: scheme.error, width: 1.5),
      disabledBorder: outline(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
      ),
    ),
  );
}

class GalleryPage extends StatelessWidget {
  const GalleryPage({
    required this.themeMode,
    required this.onThemeMode,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeMode;

  /// Whether the app is currently painting dark, whichever way it got there.
  bool _isDark(BuildContext context) => switch (themeMode) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = _isDark(context);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.surface,
            title: const Text('country_phone_kit'),
            actions: [
              IconButton(
                tooltip: dark ? 'Switch to light' : 'Switch to dark',
                icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () =>
                    onThemeMode(dark ? ThemeMode.light : ThemeMode.dark),
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PhoneFieldDemo(),
                      SizedBox(height: 20),
                      _CountryPickerDemo(),
                      SizedBox(height: 20),
                      _CurrencyPickerDemo(),
                      SizedBox(height: 20),
                      _CurrencyDropdownDemo(),
                      SizedBox(height: 20),
                      _ParseDemo(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One-line control sized like the example [TextField]s.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.leading,
    required this.label,
    required this.caption,
    required this.onTap,
  });

  final Widget leading;
  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fill = Theme.of(context).inputDecorationTheme.fillColor;

    return Material(
      color: fill ?? scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyLarge,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({
    required this.kicker,
    required this.title,
    required this.child,
  });

  final String kicker;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              kicker.toUpperCase(),
              style: text.labelSmall?.copyWith(
                color: scheme.primary,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: text.titleLarge),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _PhoneFieldDemo extends StatefulWidget {
  const _PhoneFieldDemo();

  @override
  State<_PhoneFieldDemo> createState() => _PhoneFieldDemoState();
}

class _PhoneFieldDemoState extends State<_PhoneFieldDemo> {
  late PhoneNumber _phone = PhoneNumber(country: Countries.byIsoCode('NP')!);
  bool _submitted = false;
  bool _enabled = true;

  static const _labels = CountryPickerLabels(
    title: 'Select country',
    searchHint: 'Search country or code',
    clearSearchTooltip: 'Clear search',
    emptyTitle: 'No match',
    emptyMessage: 'No country matches that name or dialling code.',
  );

  String? get _errorText {
    if (!_submitted && _phone.isEmpty) return null;
    return switch (_phone.error) {
      PhoneNumberError.empty => 'Enter a phone number',
      PhoneNumberError.tooShort => 'That number is too short',
      PhoneNumberError.tooLong => 'That number is too long',
      PhoneNumberError.invalid => 'Not a valid number for this country',
      null => null,
    };
  }

  void _submit() {
    setState(() => _submitted = true);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    if (_phone.isValid) {
      messenger.showSnackBar(
        SnackBar(content: Text('Would send ${_phone.e164}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      kicker: 'PhoneNumberField',
      title: 'Type a number',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PhoneNumberField(
            autofocus: false,
            value: _phone,
            enabled: _enabled,
            required: true,
            label: 'Mobile',
            hintText: 'National number',
            errorText: _errorText,
            textInputAction: TextInputAction.done,
            pickerLabels: _labels,
            onChanged: (number) => setState(() => _phone = number),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Enabled'),
                selected: _enabled,
                onSelected: (value) => setState(() => _enabled = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ValueBoard(phone: _phone),
          const SizedBox(height: 16),
          FilledButton(onPressed: _submit, child: const Text('Validate')),
        ],
      ),
    );
  }
}

class _ValueBoard extends StatelessWidget {
  const _ValueBoard({required this.phone});

  final PhoneNumber phone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valid = phone.isValid;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                valid ? Icons.check_circle_outline : Icons.hourglass_empty,
                size: 18,
                color: valid ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                valid ? 'Valid' : (phone.error?.name ?? 'empty'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _kv('Country', '${phone.country.flag}  ${phone.country.name}'),
          _kv('ISO', phone.country.isoCode),
          _kv(
            'National',
            phone.nationalNumber.isEmpty ? '—' : phone.nationalNumber,
          ),
          _kv('Grouped', phone.isEmpty ? '—' : phone.formatNational),
          _kv('E.164', phone.e164.isEmpty ? '—' : phone.e164),
        ],
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              key,
              style: const TextStyle(
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryPickerDemo extends StatefulWidget {
  const _CountryPickerDemo();

  @override
  State<_CountryPickerDemo> createState() => _CountryPickerDemoState();
}

class _CountryPickerDemoState extends State<_CountryPickerDemo> {
  Country _country = Countries.byIsoCode('NP')!;

  Future<void> _openSheet() async {
    final picked = await showCountryPicker(
      context: context,
      selected: _country,
    );
    if (picked == null || !mounted) return;
    setState(() => _country = picked);
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      kicker: 'showCountryPicker',
      title: 'Pick a country',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PickerField(
            onTap: _openSheet,
            leading: CountryFlag(_country.flag, size: 18),
            label: _country.name,
            caption: '${_country.isoCode}  ${_country.dialCodePrefix}',
          ),
        ],
      ),
    );
  }
}

class _CurrencyPickerDemo extends StatefulWidget {
  const _CurrencyPickerDemo();

  @override
  State<_CurrencyPickerDemo> createState() => _CurrencyPickerDemoState();
}

class _CurrencyPickerDemoState extends State<_CurrencyPickerDemo> {
  CountryCurrency _currency = Currencies.byCode('NPR')!;

  Future<void> _openSheet() async {
    final picked = await showCurrencyPicker(
      context: context,
      selected: _currency,
    );
    if (picked == null || !mounted) return;
    setState(() => _currency = picked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return _DemoCard(
      kicker: 'showCurrencyPicker',
      title: 'Pick a currency',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PickerField(
            onTap: _openSheet,
            leading: SizedBox(
              width: 28,
              child: Text(
                _currency.symbol,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            label: _currency.name,
            caption: _currency.code,
          ),
        ],
      ),
    );
  }
}

class _CurrencyDropdownDemo extends StatefulWidget {
  const _CurrencyDropdownDemo();

  @override
  State<_CurrencyDropdownDemo> createState() => _CurrencyDropdownDemoState();
}

class _CurrencyDropdownDemoState extends State<_CurrencyDropdownDemo> {
  CountryCurrency? _currency = Currencies.byCode('NPR');

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      kicker: 'CurrencyDropdownField',
      title: 'Pick a currency inline',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CurrencyDropdownField(
            label: 'Currency',
            required: true,
            value: _currency,
            onChanged: (currency) => setState(() => _currency = currency),
          ),
        ],
      ),
    );
  }
}

class _ParseDemo extends StatefulWidget {
  const _ParseDemo();

  @override
  State<_ParseDemo> createState() => _ParseDemoState();
}

class _ParseDemoState extends State<_ParseDemo> {
  final _controller = TextEditingController(text: '+1 (202) 555-0100');
  late PhoneNumber _parsed = PhoneNumber.parse(
    _controller.text,
    fallbackCountry: Countries.byIsoCode('US')!,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parse(String raw) {
    setState(() {
      _parsed = PhoneNumber.parse(
        raw,
        fallbackCountry: Countries.byIsoCode('US')!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      kicker: 'PhoneNumber.parse',
      title: 'Paste any format',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+\s\-().]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Raw input',
              hintText: '+977 098-1234-5678',
            ),
            onChanged: _parse,
          ),
          const SizedBox(height: 12),
          _ValueBoard(phone: _parsed),
        ],
      ),
    );
  }
}
