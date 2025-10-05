class Expense {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime createdAt;
  final String? notes;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      createdAt: DateTime.parse(map['created_at']),
      notes: map['notes'],
    );
  }
}

