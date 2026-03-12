part of 'transaction_cubit.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}
class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
  @override List<Object?> get props => [message];
}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final List<CategoryModel>    categories;
  final List<AccountModel>     accounts;
  final DateTime               selectedMonth;
  final double                 totalIncome;
  final double                 totalExpense;

  const TransactionLoaded({
    required this.transactions,
    required this.categories,
    required this.accounts,
    required this.selectedMonth,
    required this.totalIncome,
    required this.totalExpense,
  });

  double get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props => [
    transactions, categories, accounts,
    selectedMonth, totalIncome, totalExpense,
  ];
}