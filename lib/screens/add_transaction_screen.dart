import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Rediriger vers la page principale
            Navigator.pushNamed(context, '/home');
          },
        ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _transactionType == 'gain' ? Colors.green : Colors.grey,
                  ),
                  child: Text('Gain'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _transactionType = 'dépense';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _transactionType == 'dépense'
                        ? Colors.red
                        : Colors.grey,
                  ),
                  child: Text('Dépense'),
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
                  'comment': _commentController.text.isEmpty
                      ? null
                      : _commentController.text,
                  'date':
                      DateTime.now().toIso8601String(), // Format de date ISO
                };

                // Ajouter la transaction dans la base de données
                await DBHelper.addTransaction(transaction);

                // Afficher un message Toast
                String toastMessage = '';
                if (_transactionType == 'gain') {
                  toastMessage =
                      'Votre gain de ${amount.toStringAsFixed(2)}€ a bien été ajouté.';
                } else if (_transactionType == 'dépense') {
                  toastMessage =
                      'Votre dépense de ${amount.toStringAsFixed(2)}€ a bien été ajoutée.';
                }

                // Afficher le Toast
                Fluttertoast.showToast(
                  msg: toastMessage,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );

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
