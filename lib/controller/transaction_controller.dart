import 'package:get/get.dart';
import '../data/models/transaction_model.dart';
import '../data/services/transaction_service.dart';

class TransactionController extends GetxController {
  final TransactionService _service = TransactionService();

  var transactions = <TransactionModel>[].obs;
  var now = DateTime.now();

  // 🔵 Global totals
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  var balance = 0.0.obs;

  // 🟠 Monthly totals
  var monthlyIncome = 0.0.obs;
  var monthlyExpense = 0.0.obs;
  var monthlyBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    /// 🔥 LISTENER (MAIN FIX)
    ever(transactions, (_) {
      _calculateTotals();
      calculateMonthlyTotals(now.month, now.year);
    });

    fetchTransactions();
  }

  /// 📥 Fetch
  void fetchTransactions() async {
    final data = await _service.getTransactions();
    transactions.value = data;
  }

  /// ➕ Add
  Future<void> addTransaction(TransactionModel model) async {
    await _service.insertTransaction(model);
    fetchTransactions();
  }

  /// ❌ Delete
  Future<void> deleteTransaction(int id) async {
    await _service.deleteTransaction(id);
    fetchTransactions();
  }

  /// ✏️ Update
  Future<void> updateTransaction(TransactionModel model) async {
    await _service.updateTransaction(model);
    fetchTransactions();
  }

  /// 🔵 Global totals (FIXED)
  void _calculateTotals() {
    totalIncome.value = transactions
        .where((e) => e.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);

    totalExpense.value = transactions
        .where((e) => e.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);

    balance.value = totalIncome.value - totalExpense.value;
  }

  /// 🟠 Monthly totals
  void calculateMonthlyTotals(int month, int year) {
    double income = 0;
    double expense = 0;

    for (var tx in transactions) {
      try {
        final txDate = DateTime.parse(tx.date);

        if (txDate.month == month && txDate.year == year) {
          if (tx.type == 'income') {
            income += tx.amount;
          } else {
            expense += tx.amount;
          }
        }
      } catch (e) {
        print("Invalid date: ${tx.date}");
      }
    }

    monthlyIncome.value = income;
    monthlyExpense.value = expense;
    monthlyBalance.value = income - expense;
  }

  Map<int, Map<String, double>> getMonthlySummary(int year) {
    Map<int, Map<String, double>> data = {};

    for (var tx in transactions) {
      try {
        final date = DateTime.parse(tx.date);

        if (date.year != year) continue;

        final month = date.month;

        data.putIfAbsent(month, () => {
          "income": 0.0,
          "expense": 0.0,
        });

        if (tx.type == 'income') {
          data[month]!["income"] =
              data[month]!["income"]! + tx.amount;
        } else {
          data[month]!["expense"] =
              data[month]!["expense"]! + tx.amount;
        }
      } catch (e) {
        print("Invalid date: ${tx.date}");
      }
    }

    return data;
  }

}
