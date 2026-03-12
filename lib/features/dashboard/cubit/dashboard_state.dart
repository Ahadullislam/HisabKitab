part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}
class DashboardLoading  extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override List<Object?> get props => [message];
}

class DashboardLoaded extends DashboardState {
  final List<AccountModel>     accounts;
  final List<CategoryModel>    categories;
  final double                 monthlyIncome;
  final double                 monthlyExpense;
  final List<MonthData>        barData;
  final List<CatBreakdown>     catBreakdown;
  final List<TransactionModel> recentTx;
  final DateTime               selectedMonth;

  const DashboardLoaded({
    required this.accounts,
    required this.categories,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.barData,
    required this.catBreakdown,
    required this.recentTx,
    required this.selectedMonth,
  });

  double get totalBalance =>
      accounts.fold(0.0, (sum, a) => sum + a.balance);

  double get savingsRate => monthlyIncome == 0
      ? 0
      : ((monthlyIncome - monthlyExpense) / monthlyIncome)
      .clamp(0.0, 1.0);

  // alias so dashboard_screen can use either name
  List<MonthData> get monthlyData => barData;

  @override
  List<Object?> get props => [
    accounts, categories, monthlyIncome, monthlyExpense,
    barData, catBreakdown, recentTx, selectedMonth,
  ];
}