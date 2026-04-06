import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controller/transaction_controller.dart';
import '../core/constants/my-color.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({super.key});

  final TransactionController txController = Get.find();
  final now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final totalIncome = txController.totalIncome.value;
          final totalExpense = txController.totalExpense.value;
          final balance = txController.balance.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16), // Top spacing

                /// 🔵 Total Balance Card
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
                        "Total Balance",
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

                /// 📊 Monthly Income Chart
                _buildMiniChartCard(
                  title: "Monthly Income",
                  color: Colors.green,
                  dataKey: "income",
                ),

                const SizedBox(height: 16),

                /// 📊 Monthly Expense Chart
                _buildMiniChartCard(
                  title: "Monthly Expense",
                  color: Colors.red,
                  dataKey: "expense",
                ),

                const SizedBox(height: 16),

                /// 📊 Monthly Saving Chart (Primary Color)
                _buildMiniChartCard(
                  title: "Monthly Saving",
                  color: MyColor.primaryColor,
                  dataKey: "saving",
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 🧩 Small Card
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

  /// 📊 Mini Chart Card
  Widget _buildMiniChartCard({
    required String title,
    required Color color,
    required String dataKey,
  }) {
    final summary = txController.getMonthlySummary(now.year);

    List<FlSpot> spots = [];

    for (int month = 1; month <= 12; month++) {
      final data = summary[month] ?? {"income": 0.0, "expense": 0.0};
      double value = 0;
      if (dataKey == "income") value = data["income"]!;
      if (dataKey == "expense") value = data["expense"]!;
      if (dataKey == "saving") value = data["income"]! - data["expense"]!;

      spots.add(FlSpot(month.toDouble(), value));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 12,
                minY: 0,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipPadding: const EdgeInsets.all(6),
                    getTooltipItems: (spots) {
                      return spots.map((e) {
                        return LineTooltipItem(
                          "${e.y.toStringAsFixed(2)} EGP",
                          const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          "Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec"
                        ];
                        return Text(
                          months[value.toInt() - 1],
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 5000,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
