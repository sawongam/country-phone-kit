import 'package:flutter/material.dart';

/// A form field that looks like a [TextField] but opens a searchable list
/// anchored directly beneath it, instead of a full-screen picker sheet.
///
/// Generic over [T] so it fits any typed list — [items] plus [itemLabel] is
/// all it needs to render rows and filter them. [CurrencyDropdownField] is a
/// currency-flavoured wrapper around this; build any other flavour the same
/// way rather than reaching for this widget directly with ad hoc labels.
///
/// Controlled, like [PhoneNumberField]: it renders [value] and reports every
/// change through [onChanged], holding no selection state of its own.
///
/// ```dart
/// SearchableDropdownField<CountryCurrency>(
///   label: 'Currency',
///   required: true,
///   value: Currencies.byCode(state.currency.code),
///   items: Currencies.all,
///   itemLabel: (currency) => '${currency.name} (${currency.code})',
///   itemMatchesSearch: (currency, query) => currency.matchesQuery(query),
///   onChanged: (currency) => cubit.currencyChanged(currency),
/// )
/// ```
class SearchableDropdownField<T> extends StatefulWidget {
  /// Builds a dropdown field over [items].
  const SearchableDropdownField({
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.label,
    this.hintText,
    this.errorText,
    this.required = false,
    this.enabled = true,
    this.searchHint = 'Search',
    this.clearSearchTooltip = 'Clear search',
    this.emptySearchMessage = 'No matches',
    this.itemMatchesSearch,
    this.itemBuilder,
    this.decoration,
    this.maxMenuHeight = 320,
    super.key,
  });

  /// Every option the menu can show, in the order rows are listed.
  final List<T> items;

  /// How an item is labelled, both in the closed field and in the default row.
  final String Function(T item) itemLabel;

  /// Called with the item the user picked. Never called with null — closing
  /// the menu without a pick leaves [value] untouched.
  final ValueChanged<T> onChanged;

  /// The option currently in effect. Checked in the list; shown in the closed
  /// field.
  final T? value;

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

  /// Placeholder inside the menu's search field.
  final String searchHint;

  /// Tooltip on the search field's clear button.
  final String clearSearchTooltip;

  /// Shown in the menu when a query matches nothing.
  final String emptySearchMessage;

  /// Whether [item] matches search [query].
  ///
  /// [query] is already lowercased and trimmed. Defaults to matching
  /// [itemLabel] when omitted — pass this when an item has fields worth
  /// searching that its label does not show, the way [CountryCurrency]
  /// matches on symbol as well as name and code.
  final bool Function(T item, String query)? itemMatchesSearch;

  /// Overrides how a menu row is drawn. Defaults to a [ListTile] showing
  /// [itemLabel] with a check mark on the selected row.
  final Widget Function(BuildContext context, T item, bool selected)?
  itemBuilder;

  /// Override the entire [InputDecoration] on the closed field.
  ///
  /// When supplied, [label], [hintText] and [errorText] are ignored.
  final InputDecoration? decoration;

  /// Caps how tall the open menu can grow before its list scrolls.
  final double maxMenuHeight;

  @override
  State<SearchableDropdownField<T>> createState() =>
      _SearchableDropdownFieldState<T>();
}

class _SearchableDropdownFieldState<T>
    extends State<SearchableDropdownField<T>> {
  final LayerLink _link = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  OverlayEntry? _barrierEntry;
  OverlayEntry? _menuEntry;

  bool get _isOpen => _menuEntry != null;

  @override
  void dispose() {
    _removeMenu();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool _matches(T item, String query) {
    if (query.isEmpty) return true;
    final matcher = widget.itemMatchesSearch;
    if (matcher != null) return matcher(item, query);
    return widget.itemLabel(item).toLowerCase().contains(query);
  }

  List<T> get _visibleItems {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return widget.items;
    return widget.items.where((item) => _matches(item, query)).toList();
  }

  void _onQueryChanged(String _) {
    // The overlay is a separate element tree from this State, so its rows
    // only update when told to — a plain setState here would rebuild the
    // closed field and miss the open menu entirely.
    _menuEntry?.markNeedsBuild();
    setState(() {}); // Repaints the search field's own clear button.
  }

  void _open() {
    if (!widget.enabled || _isOpen) return;

    _search.clear();
    final overlay = Overlay.of(context);
    _barrierEntry = OverlayEntry(
      builder: (context) =>
          GestureDetector(behavior: HitTestBehavior.opaque, onTap: _close),
    );
    _menuEntry = OverlayEntry(builder: _buildMenu);
    overlay.insert(_barrierEntry!);
    overlay.insert(_menuEntry!);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _searchFocus.requestFocus(),
    );
  }

  void _close() {
    if (!_isOpen) return;
    _removeMenu();
    setState(() {});
  }

  void _removeMenu() {
    _barrierEntry?.remove();
    _menuEntry?.remove();
    _barrierEntry = null;
    _menuEntry = null;
  }

  void _select(T item) {
    widget.onChanged(item);
    _close();
  }

  Widget _buildMenu(BuildContext context) {
    final box = _fieldKey.currentContext!.findRenderObject()! as RenderBox;
    final results = _visibleItems;

    return CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      offset: Offset(0, box.size.height + 4),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: box.size.width,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxMenuHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                    child: TextField(
                      controller: _search,
                      focusNode: _searchFocus,
                      textInputAction: TextInputAction.search,
                      onChanged: _onQueryChanged,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: widget.searchHint,
                        prefixIcon: const Icon(Icons.search, size: 18),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                visualDensity: VisualDensity.compact,
                                tooltip: widget.clearSearchTooltip,
                                onPressed: () {
                                  _search.clear();
                                  _onQueryChanged('');
                                },
                              ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: results.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              widget.emptySearchMessage,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final item = results[index];
                              final selected = item == widget.value;
                              final builder = widget.itemBuilder;
                              if (builder != null) {
                                return InkWell(
                                  onTap: () => _select(item),
                                  child: builder(context, item, selected),
                                );
                              }
                              return ListTile(
                                dense: true,
                                selected: selected,
                                title: Text(widget.itemLabel(item)),
                                trailing: selected
                                    ? const Icon(Icons.check, size: 18)
                                    : null,
                                onTap: () => _select(item),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final labelText = widget.required && widget.label != null
        ? '${widget.label} *'
        : widget.label;

    return CompositedTransformTarget(
      link: _link,
      child: InkWell(
        key: _fieldKey,
        borderRadius: BorderRadius.circular(8),
        onTap: widget.enabled ? (_isOpen ? _close : _open) : null,
        child: InputDecorator(
          isEmpty: value == null,
          decoration:
              widget.decoration ??
              InputDecoration(
                labelText: labelText,
                hintText: widget.hintText,
                errorText: widget.errorText,
                enabled: widget.enabled,
                suffixIcon: Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ),
          child: Text(
            value == null ? '' : widget.itemLabel(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
