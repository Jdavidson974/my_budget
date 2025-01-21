import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart'; // Importer intl pour la gestion des dates

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  double _totalAmount = 0.0; // Total des transactions
  String _selectedType = 'all'; // 'all', 'gain', 'dépense'
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String? _formattedMonthYear; // Stocker la date formatée

  @override
  void initState() {
    super.initState();
    _loadTransactions();

    // Formater le mois et l'année
    final now = DateTime.now();
    _formattedMonthYear = DateFormat('MMMM yyyy', 'fr_FR').format(now);
  }

  // Charger les transactions depuis SQLite avec les filtres et calculer le total
  Future<void> _loadTransactions() async {
    List<Map<String, dynamic>> transactions = [];

    if (_selectedType == 'all') {
      transactions =
          await DBHelper.getTransactionsByMonth(_selectedYear, _selectedMonth);
    } else {
      transactions = await DBHelper.getTransactionsByTypeAndMonth(
          _selectedType, _selectedYear, _selectedMonth);
    }

    // Calculer le total des transactions en fonction du type sélectionné
    double total = 0.0;
    for (var transaction in transactions) {
      double amount = transaction['amount'];
      if (_selectedType == 'gain') {
        total += amount; // Ajouter uniquement les gains
      } else if (_selectedType == 'dépense') {
        total -= amount; // Soustraire uniquement les dépenses
      } else {
        // Si 'all' est sélectionné, additionner les gains et soustraire les dépenses
        if (transaction['type'] == 'gain') {
          total += amount;
        } else if (transaction['type'] == 'dépense') {
          total -= amount;
        }
      }
    }

    setState(() {
      _transactions = transactions;
      _totalAmount = total; // Mettre à jour le total
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
        // Mettre à jour la valeur formatée après sélection du mois
        _formattedMonthYear = DateFormat('MMMM yyyy', 'fr_FR').format(picked);
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
                SizedBox(width: 10),
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
                      child: Text(value == 'all' ? 'Tous' : capitalize(value)),
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
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectMonth(context),
                  child: Row(
                    children: [
                      Icon(IconData(0xe122, fontFamily: 'MaterialIcons')),
                      SizedBox(width: 10),
                      // Affichage du mois et de l'année formatés
                      Text(_formattedMonthYear ?? ''),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Affichage du total
            Text(
              'Total des transactions: ${_totalAmount.toStringAsFixed(2)} €',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _totalAmount >= 0 ? Colors.green : Colors.red,
              ),
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
                        // Formater la date dans le format YY/MM/YYYY
                        final transactionDate = DateFormat('yy/MM/yyyy')
                            .format(DateTime.parse(transaction['date']));

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
                            transactionDate,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ), // Affiche la date formatée
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String capitalize(string) {
    return "${string[0].toUpperCase()}${string.substring(1).toLowerCase()}";
  }
}
