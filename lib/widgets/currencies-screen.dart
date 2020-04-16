import 'package:flutter/material.dart';
import 'package:portfolio/model/currencies.dart';
import 'package:provider/provider.dart';

class CurrenciesScreen extends StatefulWidget {
  final bool fiats;
  final void Function(Currency currency) onSelected;

  const CurrenciesScreen({Key key, this.fiats = false, this.onSelected})
      : super(key: key);

  @override
  _CurrenciesScreenState createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  static final emptyFilter = (_) => true;

  bool _searchMode = false;
  bool Function(Currency) _filter = emptyFilter;

  @override
  void initState() {
    super.initState();
  }

  onSearchChanged(String search) {
    setState(() {
      if (search.trim() == '') _filter = emptyFilter;
      _filter = (currency) =>
          currency.name.toLowerCase().contains(search.trim().toLowerCase()) ||
          currency.symbol.toLowerCase().contains(search.trim().toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencies = Provider.of<Currencies>(context);
    final currenciesList =
        (widget.fiats ? currencies.fiats : currencies.cryptos)
            .where(_filter)
            .toList();
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
            : Text('Cryptocurrency'),
        actions: [
          IconButton(
            icon: _searchMode ? Icon(Icons.close) : Icon(Icons.search),
            onPressed: () {
              setState(() {
                if (_searchMode) {
                  _filter = emptyFilter;
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
