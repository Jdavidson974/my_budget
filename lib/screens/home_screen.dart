import 'package:flutter/material.dart';
import 'package:my_budget/database/database_helper.dart';
import 'package:my_budget/screens/add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _currentBudget = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  // Charger le budget actuel
  Future<void> _loadBudget() async {
    List<Map<String, dynamic>> transactions = await DBHelper.getTransactions();
    double budget = 0.0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'gain') {
        budget += transaction['amount'];
      } else if (transaction['type'] == 'dépense') {
        budget -= transaction['amount'];
      }
    }

    setState(() {
      _currentBudget = budget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My-Budget'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Budget Actuel : ${_currentBudget.toStringAsFixed(2)}€',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTransactionScreen()),
                );
                if (result == true) {
                  // Recharger le budget après l'ajout
                  _loadBudget();
                }
              },
              child: Text('Ajouter une Transaction'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              child: Text('Voir Historique'),
            ),
          ],
        ),
      ),
    );
  }
}
