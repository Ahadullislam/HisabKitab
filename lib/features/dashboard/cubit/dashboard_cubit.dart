import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../models/dashboard_models.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final AccountRepository     _accountRepo;
  final TransactionRepository _txRepo;

  DashboardCubit(this._accountRepo, this._txRepo)
      : super(DashboardInitial()) {
    load();
  }

  Future<void> load() async {
    emit(DashboardLoading());
    try {
      final accounts   = _accountRepo.getAll();
      final categories = Hive.box<CategoryModel>(HiveBoxes.categories)
          .values.toList();
      final now        = DateTime.now();

      final income  = _txRepo.totalIncomeForMonth(now.month, now.year);
      final expense = _txRepo.totalExpenseForMonth(now.month, now.year);

      // 6-month bar data
      final barData = <MonthData>[];
      for (int i = 5; i >= 0; i--) {
        final m = DateTime(now.year, now.month - i, 1);
        barData.add(MonthData(
          label:   _monthLabel(m.month),
          income:  _txRepo.totalIncomeForMonth(m.month, m.year),
          expense: _txRepo.totalExpenseForMonth(m.month, m.year),
        ));
      }

      // Category breakdown
      final catSpend = _txRepo.expenseByCategory(now.month, now.year);
      final totalExp = catSpend.values.fold(0.0, (s, v) => s + v);
      final catList  = catSpend.entries.map((e) {
        final cat = categories.cast<CategoryModel?>()
            .firstWhere((c) => c?.id == e.key, orElse: () => null);
        return CatBreakdown(
          name:       cat?.name      ?? 'Other',
          amount:     e.value,
          percent:    totalExp == 0 ? 0 : e.value / totalExp,
          colorValue: cat?.colorValue ?? 0xFF607D8B,
          icon:       cat?.icon       ?? '💸',
        );
      }).toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      // Recent 5 transactions — typed as TransactionModel
      final allTx = _txRepo.getAll()
        ..sort((a, b) => b.date.compareTo(a.date));
      final recentTx = allTx.take(5).toList();

      emit(DashboardLoaded(
        accounts:       accounts,
        categories:     categories,
        monthlyIncome:  income,
        monthlyExpense: expense,
        barData:        barData,
        catBreakdown:   catList.take(6).toList(),
        recentTx:       recentTx,
        selectedMonth:  now,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  String _monthLabel(int month) {
    const labels = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return labels[month - 1];
  }
}