import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finance/screen/transaction_details_screen.dart';
import '../controller/transaction_controller.dart';
import '../data/models/transaction_model.dart';
import '../core/constants/my-color.dart';

class TransactionsScreen extends StatefulWidget {
  TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionController controller = Get.find();
  final TextEditingController searchController = TextEditingController();
  var searchText = ''.obs;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      searchText.value = searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Search Field
              TextField(
                controller: searchController,
                cursorColor: MyColor.primaryColor,
                decoration: InputDecoration(
                  hintText: 'Search by category',
                  hintStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: MyColor.primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Transaction List
              Expanded(
                child: Obx(() {
                  if (controller.transactions.isEmpty) {
                    return const Center(
                        child: Text('No transactions yet.',
                            style: TextStyle(fontSize: 16)));
                  }

                  final filteredTransactions = controller.transactions
                      .where((tx) =>
                      tx.category.toLowerCase().contains(searchText.value))
                      .toList();

                  if (filteredTransactions.isEmpty) {
                    return const Center(
                        child: Text('No matching transactions.',
                            style: TextStyle(fontSize: 16)));
                  }

                  // Group by month-year
                  final Map<String, List<TransactionModel>> grouped = {};
                  for (var tx in filteredTransactions) {
                    final date = DateTime.parse(tx.date);
                    final key =
                        "${date.year}-${date.month.toString().padLeft(2, '0')}";
                    grouped.putIfAbsent(key, () => []).add(tx);
                  }

                  final sortedKeys = grouped.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  return ListView.builder(
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      final key = sortedKeys[index];
                      final txs = grouped[key]!;

                      final dateParts = key.split('-');
                      final month = int.parse(dateParts[1]);
                      final year = int.parse(dateParts[0]);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Month Header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "${_monthName(month)} $year",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: MyColor.primaryColor),
                            ),
                          ),

                          /// Transactions for the month
                          ...txs.map(
                                (tx) => Card(
                              color: Colors.white,
                              elevation: 6,
                              shadowColor: MyColor.primaryColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Text(
                                  "${tx.category} - ${tx.amount.toStringAsFixed(2)} EGP",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(tx.date),
                                trailing: Text(
                                  tx.type,
                                  style: TextStyle(
                                      color: tx.type == 'income'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  Get.to(() => TransactionDetailScreen(
                                      transaction: tx));
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return names[month];
  }
}
