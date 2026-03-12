import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/account_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/local/hive_boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _txRepo;
  final AccountRepository     _accRepo;

  TransactionCubit(this._txRepo, this._accRepo)
      : super(TransactionInitial()) {
    loadTransactions();
  }

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  void loadTransactions() {
    emit(TransactionLoading());
    try {
      final txs  = _txRepo.getByMonth(
          _selectedMonth.month, _selectedMonth.year);
      final cats = Hive.box<CategoryModel>(HiveBoxes.categories).values.toList();
      final accs = _accRepo.getAll();
      emit(TransactionLoaded(
        transactions: txs,
        categories: cats,
        accounts: accs,
        selectedMonth: _selectedMonth,
        totalIncome:  _txRepo.totalIncomeForMonth(
            _selectedMonth.month, _selectedMonth.year),
        totalExpense: _txRepo.totalExpenseForMonth(
            _selectedMonth.month, _selectedMonth.year),
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void changeMonth(DateTime month) {
    _selectedMonth = month;
    loadTransactions();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await _txRepo.add(tx);
    await _accRepo.updateBalance(
      tx.accountId,
      tx.isIncome ? tx.amount : -tx.amount,
    );
    loadTransactions();
  }

  Future<void> updateTransaction(
      TransactionModel old, TransactionModel updated) async {
    // Reverse old effect
    await _accRepo.updateBalance(
      old.accountId,
      old.isIncome ? -old.amount : old.amount,
    );
    // Apply new effect
    await _txRepo.update(updated);
    await _accRepo.updateBalance(
      updated.accountId,
      updated.isIncome ? updated.amount : -updated.amount,
    );
    loadTransactions();
  }

  Future<void> deleteTransaction(TransactionModel tx) async {
    await _accRepo.updateBalance(
      tx.accountId,
      tx.isIncome ? -tx.amount : tx.amount,
    );
    await _txRepo.delete(tx.id);
    loadTransactions();
  }
}