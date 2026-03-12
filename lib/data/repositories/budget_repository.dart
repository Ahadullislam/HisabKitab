import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget_model.dart';
import '../local/hive_boxes.dart';

class BudgetRepository {
  Box<BudgetModel> get _budgetBox =>
      Hive.box<BudgetModel>(HiveBoxes.budgets);

  Box<BillReminderModel> get _billBox =>
      Hive.box<BillReminderModel>(HiveBoxes.billReminders);

  // ── Budgets ────────────────────────────────────────────────
  List<BudgetModel> getAll() => _budgetBox.values.toList();

  List<BudgetModel> getForMonth(int month, int year) =>
      getAll().where(
              (b) => b.month == month && b.year == year).toList();

  BudgetModel? getForCategory(
      String categoryId, int month, int year) {
    try {
      return getForMonth(month, year)
          .firstWhere((b) => b.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBudget(BudgetModel b) async =>
      _budgetBox.put(b.id, b);

  Future<void> deleteBudget(String id) async =>
      _budgetBox.delete(id);

  // ── Bill Reminders ─────────────────────────────────────────
  List<BillReminderModel> getAllBills() =>
      _billBox.values.toList()
        ..sort((a, b) => a.dayOfMonth.compareTo(b.dayOfMonth));

  Future<void> saveBill(BillReminderModel b) async =>
      _billBox.put(b.id, b);

  Future<void> deleteBill(String id) async =>
      _billBox.delete(id);

  ValueListenable<Box<BudgetModel>> budgetListenable() =>
      _budgetBox.listenable();

  ValueListenable<Box<BillReminderModel>> billListenable() =>
      _billBox.listenable();
}