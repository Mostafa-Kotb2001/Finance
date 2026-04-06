class BudgetModel {
  int? id;
  int month;
  int year;
  double monthlyLimit;

  BudgetModel({this.id, required this.month, required this.year, required this.monthlyLimit});

  Map<String, dynamic> toMap() => {
    'id': id,
    'month': month,
    'year': year,
    'monthly_limit': monthlyLimit,
  };

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
    id: map['id'],
    month: map['month'],
    year: map['year'],
    monthlyLimit: map['monthly_limit'],
  );
}
