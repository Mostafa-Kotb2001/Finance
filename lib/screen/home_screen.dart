import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finance/core/constants/my-color.dart';
import '../controller/transaction_controller.dart';
import '../controller/budget_controller.dart';
import '../widgets/budget_dialog.dart';
import 'add_transaction_screen.dart';
import '../data/models/budget_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransactionController txController = Get.find();
  final BudgetController budgetController = Get.put(BudgetController());

  final now = DateTime.now();


  @override
  void initState() {
    super.initState();

    // Load monthly data once
    txController.calculateMonthlyTotals(now.month, now.year);
    budgetController.loadBudget(now.month, now.year);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final balance = txController.monthlyBalance.value;
          final totalIncome = txController.monthlyIncome.value;
          final totalExpense = txController.monthlyExpense.value;

          final monthlyBudget = budgetController.monthlyBudget.value;
          final remainingBudget = monthlyBudget - totalExpense;

          final budgetProgress =
              totalExpense / (monthlyBudget > 0 ? monthlyBudget : 1);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 20,),
                /// 🔵 Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: MyColor.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Current Balance (This Month)",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${balance.toStringAsFixed(2)} EGP",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// 🟢 Income & 🔴 Expense Cards
                Row(
                  children: [
                    _buildCard("Income", totalIncome, Colors.green),
                    const SizedBox(width: 10),
                    _buildCard("Expense", totalExpense, Colors.red),
                  ],
                ),

                const SizedBox(height: 16),

                /// 🟠 Budget Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MyColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Monthly Budget",
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: budgetProgress > 1 ? 1 : budgetProgress,
                        backgroundColor: Colors.grey.shade300,
                        color: MyColor.primaryColor,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Remaining: ${remainingBudget.toStringAsFixed(2)} EGP",
                      ),
                      if (budgetProgress > 0.8 && budgetProgress < 1)
                        const Text(
                          "Warning: Approaching budget limit!",
                          style: TextStyle(color: Colors.red),
                        ),
                      if (budgetProgress > 1 )
                        const Text(
                          "You have exceeded the maximum limit",
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _showBudgetDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColor.primaryColor,
                        ),
                        child: const Text("Set Budget" , style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 270),

                /// ➕ Add Income / Expense Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Get.to(() =>
                          const AddTransactionScreen(type: 'Income'));
                          txController.calculateMonthlyTotals(
                              now.month, now.year);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Add Income" , style: TextStyle(color: Colors.white , fontSize: 16),),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Get.to(() =>
                          const AddTransactionScreen(type: 'Expense'));
                          txController.calculateMonthlyTotals(
                              now.month, now.year);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Add Expense", style: TextStyle(color: Colors.white , fontSize: 16),),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 🧩 Card Widget
  Widget _buildCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(
              "${amount.toStringAsFixed(2)} EGP",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 💰 Budget Dialog
  void _showBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BudgetDialog(
        initialBudget: budgetController.monthlyBudget.value,
        onSave: (value) {
          final budget = BudgetModel(
            month: now.month,
            year: now.year,
            monthlyLimit: value,
          );
          budgetController.setBudget(budget);
        },
      ),
    );
  }
}
