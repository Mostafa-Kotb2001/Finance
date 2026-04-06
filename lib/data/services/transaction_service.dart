import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final dbHelper = DatabaseHelper.instance;

  // INSERT
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  // GET ALL
  Future<List<TransactionModel>> getTransactions() async {
    final db = await dbHelper.database;
    final result = await db.query('transactions', orderBy: 'date DESC');

    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }

  // UPDATE
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;

    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // DELETE
  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.database;

    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
