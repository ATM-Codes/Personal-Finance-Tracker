class Expense {
  final int? id;
  final double amount;
  final int catId;
  final String desc;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.amount,
    required this.catId,
    required this.desc,
    required this.date,
    required this.createdAt,
  });

  //convert category to map to the database

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'catId': catId,
      'desc': desc,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  //convert map values to category from the db
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      catId: map['catId'] as int,
      desc: map['desc'] as String,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
