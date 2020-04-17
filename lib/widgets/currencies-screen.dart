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
  bool _searchMode = false;
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
        title: _searchMode
            ? TextField(
                autofocus: true,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Search…',
                  isDense: true,
                ),
                onChanged: onSearchChanged,
              )
            : Text(widget.title),
        actions: [
          IconButton(
            icon: _searchMode ? Icon(Icons.close) : Icon(Icons.search),
            onPressed: () {
              setState(() {
                if (_searchMode) {
                  _search = '';
                }
                _searchMode = !_searchMode;
              });
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: currenciesList.length * 2,
        itemBuilder: (_, i) {
          if (i.isOdd) return Divider(height: 1);
          final index = i ~/ 2;
          var currency = currenciesList[index];
          return ListTile(
            title: Text(currency.name),
            trailing: widget.showSymbols ? Text(currency.symbol) : null,
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
