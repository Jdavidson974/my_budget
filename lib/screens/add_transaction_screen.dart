import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String _transactionType = 'gain'; // 'gain' ou 'dépense'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Sélection du type de transaction
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _transactionType = 'gain';
                    });
                  },
                  child: Text('Gain'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _transactionType == 'gain' ? Colors.green : Colors.grey,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _transactionType = 'dépense';
                    });
                  },
                  child: Text('Dépense'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _transactionType == 'dépense'
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Saisie du montant
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Montant (€)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Saisie du commentaire
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Commentaire',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Bouton pour enregistrer la transaction
            ElevatedButton(
              onPressed: () async {
                // Vérifier que le montant est bien renseigné
                final double? amount = double.tryParse(_amountController.text);
                if (amount == null || amount <= 0) {
                  // Afficher une erreur si le montant est invalide
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Veuillez entrer un montant valide')),
                  );
                  return;
                }

                // Créer un objet transaction
                final transaction = {
                  'type': _transactionType,
                  'amount': amount,
                  'comment': _commentController.text,
                  'date':
                      DateTime.now().toIso8601String(), // Format de date ISO
                };

                // Ajouter la transaction dans la base de données
                await DBHelper.addTransaction(transaction);

                // Retour à l'écran principal avec une confirmation
                Navigator.pop(context,
                    true); // Retourner "true" pour signaler que la transaction a été ajoutée
              },
              child: Text('Ajouter la transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
