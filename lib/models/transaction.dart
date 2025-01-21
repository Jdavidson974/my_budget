class Transaction {
  final int? id;
  final String type;
  final double amount;
  final String? comment;
  final String date;

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    this.comment,
    required this.date,
  });

  // Conversion d'une Transaction en Map (utilisé pour l'insertion dans la base de données)
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'comment': comment,
      'date': date,
    };
  }

  // Convertir une Map en Transaction
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      comment: map['comment'],
      date: map['date'],
    );
  }
}
