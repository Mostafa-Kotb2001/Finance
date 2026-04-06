class TransactionModel {
  final int? id;
  final double amount;
  final String type; // income or expense
  final String category;
  final String date;
  final String note;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
  });

  // Convert object → Map (for DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'note': note,
    };
  }

  // Convert Map → object
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      date: map['date'],
      note: map['note'] ?? '',
    );
  }
}
