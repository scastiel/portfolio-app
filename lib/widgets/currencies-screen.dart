import 'package:flutter/material.dart';
import 'package:portfolio/model/currencies.dart';
import 'package:provider/provider.dart';

class CurrenciesScreen extends StatefulWidget {
  final bool fiats;
  final void Function(Currency currency) onSelected;
  final String title;
  final bool showSymbols;

  const CurrenciesScreen({
    Key key,
    this.fiats = false,
    this.onSelected,
    this.title = '',
    this.showSymbols = false,
  }) : super(key: key);

  @override
  _CurrenciesScreenState createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
  }

  onSearchChanged(String search) {
    setState(() {
      _search = search.trim().toLowerCase();
    });
  }

  List<Currency> _getCurrenciesList(Currencies currencies) {
    final list =
        (widget.fiats ? currencies.fiats : currencies.cryptos).toList();
    list.sort(
        (c1, c2) => c1.name.toLowerCase().compareTo(c2.name.toLowerCase()));

    if (_search == '') return list;

    int _getCurrencyScore(Currency currency) {
      final name = currency.name.toLowerCase();
      final symbol = currency.symbol.toLowerCase();
      if (name == _search) return 1;
      if (symbol == _search) return 2;
      if (name.startsWith(_search)) return 3;
      if (symbol.startsWith(_search)) return 4;
      if (name.contains(_search)) return 5;
      if (symbol.contains(_search)) return 6;
      return 0;
    }

    final results =
        list.where((element) => _getCurrencyScore(element) > 0).toList();
    results.sort(
      (c1, c2) => _getCurrencyScore(c1).compareTo(_getCurrencyScore(c2)),
    );
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final currencies = Provider.of<Currencies>(context);
    final currenciesList = _getCurrenciesList(currencies);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Search…',
            isDense: true,
          ),
          onChanged: onSearchChanged,
        ),
      ),
      body: ListView.builder(
        itemCount: currenciesList.length * 2,
        itemBuilder: (_, i) {
          if (i.isOdd) return Divider(height: 1);
          final index = i ~/ 2;
          var currency = currenciesList[index];
          return ListTile(
            title: RichText(
              text: _highlightSearch(currency.name),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: widget.showSymbols
                ? RichText(
                    text: _highlightSearch(currency.symbol),
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            onTap: () {
              if (widget.onSelected != null) {
                widget.onSelected(currency);
              }
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }

  TextSpan _highlightSearch(String label) {
    final style = Theme.of(context).textTheme.bodyText2;
    final index = label.indexOf(new RegExp(_search, caseSensitive: false));
    if (index == -1 || _search == '') {
      return TextSpan(text: label, style: style);
    }
    final before = label.substring(0, index);
    final highlight = label.substring(index, index + _search.length);
    final after = label.substring(index + _search.length);
    return TextSpan(
      children: [
        TextSpan(
          text: before,
          style: style,
        ),
        TextSpan(
          text: highlight,
          style: style.copyWith(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: after,
          style: style,
        ),
      ],
    );
  }
}

void showCurrenciesScreen(
  BuildContext context, {
  title = '',
  void onSelected(Currency currency),
  fiats = false,
  showSymbols = false,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) {
        return CurrenciesScreen(
          fiats: fiats,
          onSelected: onSelected,
          title: title,
          showSymbols: showSymbols,
        );
      },
    ),
  );
}
