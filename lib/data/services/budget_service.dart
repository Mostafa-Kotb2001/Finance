import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/budget_model.dart';

class BudgetService {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertBudget(BudgetModel budget) async {
    final db = await dbHelper.database;
    return await db.insert('budget', budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<BudgetModel?> getBudget(int month, int year) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'budget',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    if (result.isNotEmpty) return BudgetModel.fromMap(result.first);
    return null;
  }

  Future<int> updateBudget(BudgetModel budget) async {
    final db = await dbHelper.database;
    return await db.update('budget', budget.toMap(),
        where: 'id = ?', whereArgs: [budget.id]);
  }
}
