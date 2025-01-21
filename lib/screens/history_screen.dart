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

  // Fonction pour supprimer une transaction
  Future<void> _deleteTransaction(int transactionId) async {
    await DBHelper.deleteTransaction(transactionId);
    _loadTransactions();
  }

  // Fonction pour modifier une transaction
  Future<void> _editTransaction(Map<String, dynamic> transaction) async {
    TextEditingController amountController =
        TextEditingController(text: transaction['amount'].toString());
    TextEditingController commentController =
        TextEditingController(text: transaction['comment']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modifier la transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                transaction['type'],
                style: TextStyle(
                    color: transaction["type"] == "gain"
                        ? Colors.green
                        : Colors.red),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Montant'),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(labelText: 'Commentaire'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                double newAmount =
                    double.tryParse(amountController.text) ?? 0.0;
                String newComment = commentController.text;

                if (newAmount != transaction['amount'] ||
                    newComment != transaction['comment']) {
                  await DBHelper.updateTransaction(transaction['id'], newAmount,
                      newComment.isEmpty ? "Aucun commentaire" : newComment);
                  _loadTransactions();
                }

                Navigator.of(context).pop();
              },
              child: Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Rediriger vers la page principale
            Navigator.pushNamed(context, '/home');
          },
        ),
        title: Text('Historique des Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Filtre par type
            _transactions.isEmpty
                ? Text("")
                : Row(
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
                            child: Text(
                                value == 'all' ? 'Tous' : capitalize(value)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
            SizedBox(height: 20),

            // Filtre par mois
            _transactions.isEmpty
                ? Text("")
                : Row(
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
            _transactions.isEmpty
                ? Text("")
                : Text(
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
                          subtitle: Text(transaction['comment'] ??
                              'Aucun commentaire'), // Commentaire ici
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                transactionDate,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              // Icône poubelle pour la suppression
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  // Afficher une boîte de dialogue de confirmation avant de supprimer
                                  bool? shouldDelete = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            Text("Confirmation de suppression"),
                                        content: Text(
                                            "Voulez-vous vraiment supprimer cette transaction ?"),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Annuler'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Supprimer'),
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  // Si l'utilisateur confirme, supprimer la transaction
                                  if (shouldDelete == true) {
                                    await _deleteTransaction(transaction['id']);
                                  }
                                },
                              ),
                              // Affichage de la date dans trailing
                            ],
                          ),
                          onTap: () => _editTransaction(
                              transaction), // Modifier la transaction
                        );
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }

  String capitalize(string) {
    return "${string[0].toUpperCase()}${string.substring(1).toLowerCase()}";
  }
}
