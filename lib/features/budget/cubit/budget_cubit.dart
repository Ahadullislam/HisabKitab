import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository      _budgetRepo;
  final TransactionRepository _txRepo;
  final NotificationService   _notifService;

  BudgetCubit(this._budgetRepo, this._txRepo, this._notifService)
      : super(BudgetInitial()) {
    load();
  }

  DateTime _month = DateTime.now();

  void load() {
    emit(BudgetLoading());
    try {
      final categories = Hive.box<CategoryModel>(HiveBoxes.categories)
          .values
          .where((c) => !c.isIncome)
          .toList();

      final budgets = _budgetRepo.getForMonth(_month.month, _month.year);
      final bills   = _budgetRepo.getAllBills();

      final catSpending = _txRepo.expenseByCategory(
          _month.month, _month.year);

      final items = categories.map((cat) {
        final budget  = budgets.cast<BudgetModel?>()
            .firstWhere((b) => b?.categoryId == cat.id,
            orElse: () => null);
        final spent   = catSpending[cat.id] ?? 0;
        final percent = budget == null || budget.limitAmount == 0
            ? 0.0
            : (spent / budget.limitAmount).clamp(0.0, 1.0);

        return BudgetItem(
          category:    cat,
          budget:      budget,
          spent:       spent,
          percent:     percent,
          isOverspent: budget != null && spent > budget.limitAmount,
          isNearLimit: budget != null &&
              percent >= 0.8 && spent <= budget.limitAmount,
        );
      }).toList()
        ..sort((a, b) {
          // Sort: over budget first, then near limit, then has budget,
          // then no budget
          if (a.isOverspent && !b.isOverspent) return -1;
          if (!a.isOverspent && b.isOverspent) return 1;
          if (a.isNearLimit && !b.isNearLimit) return -1;
          if (!a.isNearLimit && b.isNearLimit) return 1;
          if (a.hasBudget && !b.hasBudget)     return -1;
          if (!a.hasBudget && b.hasBudget)     return 1;
          return b.spent.compareTo(a.spent);
        });

      final totalBudget = budgets.fold(0.0, (s, b) => s + b.limitAmount);
      final totalSpent  = catSpending.values.fold(0.0, (s, v) => s + v);

      emit(BudgetLoaded(
        items:        items,
        bills:        bills,
        totalBudget:  totalBudget,
        totalSpent:   totalSpent,
        selectedMonth: _month,
      ));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  // ── Budget CRUD ──────────────────────────────────────────────
  Future<void> setBudget(
      String categoryId, double limit) async {
    final existing = _budgetRepo.getForCategory(
        categoryId, _month.month, _month.year);

    final model = existing?.copyWith(limitAmount: limit) ??
        BudgetModel(
          categoryId:  categoryId,
          limitAmount: limit,
          month:       _month.month,
          year:        _month.year,
        );

    await _budgetRepo.saveBudget(model);
    load();
    _checkAlerts();
  }

  Future<void> deleteBudget(String categoryId) async {
    final existing = _budgetRepo.getForCategory(
        categoryId, _month.month, _month.year);
    if (existing != null) {
      await _budgetRepo.deleteBudget(existing.id);
    }
    load();
  }

  // ── Bill CRUD ────────────────────────────────────────────────
  Future<void> saveBill(BillReminderModel bill) async {
    await _budgetRepo.saveBill(bill);
    if (bill.isActive) {
      await _scheduleNotification(bill);
    }
    load();
  }

  Future<void> toggleBill(BillReminderModel bill) async {
    final updated = bill.copyWith(isActive: !bill.isActive);
    await _budgetRepo.saveBill(updated);
    if (updated.isActive) {
      await _scheduleNotification(updated);
    } else {
      await _notifService.cancelNotification(bill.id.hashCode);
    }
    load();
  }

  Future<void> deleteBill(BillReminderModel bill) async {
    await _notifService.cancelNotification(bill.id.hashCode);
    await _budgetRepo.deleteBill(bill.id);
    load();
  }

  // ── Alerts ───────────────────────────────────────────────────
  void _checkAlerts() {
    final state = this.state;
    if (state is! BudgetLoaded) return;
    for (final item in state.items) {
      if (item.budget == null) continue;
      if (item.isOverspent || item.isNearLimit) {
        _notifService.showBudgetAlert(
          categoryName: item.category.name,
          spent:        item.spent,
          limit:        item.budget!.limitAmount,
          isOverspent:  item.isOverspent,
        );
      }
    }
  }

  Future<void> _scheduleNotification(BillReminderModel bill) async {
    final due = bill.nextDueDate();
    final notifDate = due.subtract(const Duration(days: 2));
    if (notifDate.isAfter(DateTime.now())) {
      await _notifService.scheduleBillReminder(
        id:            bill.id.hashCode,
        title:         bill.title,
        body:          'Your ${bill.title} bill of '
            '৳${bill.amount.toStringAsFixed(0)} '
            'is due in 2 days (${due.day}/${due.month}).',
        scheduledDate: notifDate,
      );
    }
  }

  void changeMonth(DateTime month) {
    _month = month;
    load();
  }
}