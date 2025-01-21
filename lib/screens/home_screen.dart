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

  // Charger le budget actuel depuis la base de données
  Future<void> _loadBudget() async {
    double budget = await DBHelper.getCurrentBalance();
    setState(() {
      _currentBudget = budget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text(""),
        title: Text('My-Budget'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Affichage du budget actuel
            Text(
              'Budget Actuel : ${_currentBudget.toStringAsFixed(2)}€',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _currentBudget > 0
                    ? Colors.green
                    : _currentBudget == 0
                        ? Colors.black
                        : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            // Ajouter une transaction
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTransactionScreen()),
                );
                if (result == true) {
                  _loadBudget();
                }
              },
              child: Text('Ajouter une Transaction'),
            ),
            // Voir l'historique des transactions
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
