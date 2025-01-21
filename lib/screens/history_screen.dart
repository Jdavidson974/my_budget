import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  String _selectedType = 'all'; // 'all', 'gain', 'dépense'
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Charger les transactions depuis SQLite avec les filtres
  Future<void> _loadTransactions() async {
    List<Map<String, dynamic>> transactions = [];

    if (_selectedType == 'all') {
      transactions =
          await DBHelper.getTransactionsByMonth(_selectedYear, _selectedMonth);
    } else {
      transactions = await DBHelper.getTransactionsByTypeAndMonth(
          _selectedType, _selectedYear, _selectedMonth);
    }

    setState(() {
      _transactions = transactions;
    });
  }

  // Méthode pour afficher un sélecteur de mois et année

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != DateTime(_selectedYear, _selectedMonth)) {
      setState(() {
        _selectedYear = picked.year;
        _selectedMonth = picked.month;
      });
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Filtre par type
            Row(
              children: <Widget>[
                Text('Filtrer par type: '),
                DropdownButton<String>(
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                    _loadTransactions();
                  },
                  items: <String>['all', 'gain', 'dépense']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'all' ? 'Tous' : value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Filtre par mois
            Row(
              children: <Widget>[
                Text('Filtrer par mois: '),
                ElevatedButton(
                  onPressed: () => _selectMonth(context),
                  child: Text('$_selectedMonth/$_selectedYear'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Liste des transactions
            _transactions.isEmpty
                ? Center(child: Text('Aucune transaction enregistrée.'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return ListTile(
                          title: Text(
                            '${transaction['amount'].toStringAsFixed(2)}€',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: transaction['type'] == 'gain'
                                  ? const Color.fromARGB(255, 25, 170, 86)
                                  : const Color.fromARGB(255, 175, 56, 48),
                            ),
                          ),
                          subtitle: Text(
                              transaction['comment'] ?? 'Aucun commentaire'),
                          trailing: Text(
                            transaction['date'].substring(0, 10),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ), // Affiche uniquement la date
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
