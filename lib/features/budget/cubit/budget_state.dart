part of 'budget_cubit.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();
  @override List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}
class BudgetLoading  extends BudgetState {}

class BudgetError extends BudgetState {
  final String message;
  const BudgetError(this.message);
  @override List<Object?> get props => [message];
}

class BudgetLoaded extends BudgetState {
  final List<BudgetItem>         items;
  final List<BillReminderModel>  bills;
  final double                   totalBudget;
  final double                   totalSpent;
  final DateTime                 selectedMonth;

  const BudgetLoaded({
    required this.items,
    required this.bills,
    required this.totalBudget,
    required this.totalSpent,
    required this.selectedMonth,
  });

  double get totalPercent => totalBudget == 0
      ? 0.0
      : (totalSpent / totalBudget).clamp(0.0, 1.0);

  int get overspentCount  =>
      items.where((i) => i.isOverspent).length;
  int get nearLimitCount  =>
      items.where((i) => i.isNearLimit).length;
  int get activeBillCount =>
      bills.where((b) => b.isActive).length;

  @override
  List<Object?> get props => [
    items, bills, totalBudget, totalSpent, selectedMonth,
  ];
}

class BudgetItem extends Equatable {
  final CategoryModel  category;
  final BudgetModel?   budget;
  final double         spent;
  final double         percent;
  final bool           isOverspent;
  final bool           isNearLimit;

  const BudgetItem({
    required this.category,
    required this.budget,
    required this.spent,
    required this.percent,
    required this.isOverspent,
    required this.isNearLimit,
  });

  bool get hasBudget => budget != null;

  @override
  List<Object?> get props => [
    category, budget, spent, percent, isOverspent, isNearLimit,
  ];
}