import 'package:get/get.dart';
import '../data/models/budget_model.dart';
import '../data/services/budget_service.dart';

class BudgetController extends GetxController {
  final BudgetService _service = BudgetService();

  var monthlyBudget = 0.0.obs;

  Future<void> loadBudget(int month, int year) async {
    final budget = await _service.getBudget(month, year);
    monthlyBudget.value = budget?.monthlyLimit ?? 0.0;
  }

  Future<void> setBudget(BudgetModel budget) async {
    final existing = await _service.getBudget(budget.month, budget.year);
    if (existing == null) {
      await _service.insertBudget(budget);
    } else {
      await _service.updateBudget(BudgetModel(
        id: existing.id,
        month: budget.month,
        year: budget.year,
        monthlyLimit: budget.monthlyLimit, // fixed here
      ));
    }

    // Update the reactive value
    monthlyBudget.value = budget.monthlyLimit; // fixed here
  }
}
