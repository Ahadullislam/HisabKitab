import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../local/hive_boxes.dart';

class TransactionRepository {
  Box<TransactionModel> get _box =>
      Hive.box<TransactionModel>(HiveBoxes.transactions);

  List<TransactionModel> getAll() =>
      _box.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<TransactionModel> getByMonth(int month, int year) =>
      getAll().where((t) =>
      t.date.month == month && t.date.year == year).toList();

  Future<void> add(TransactionModel t)    async => _box.put(t.id, t);
  Future<void> update(TransactionModel t) async => _box.put(t.id, t);
  Future<void> delete(String id)          async => _box.delete(id);

  double totalIncomeForMonth(int month, int year) =>
      getByMonth(month, year)
          .where((t) => t.isIncome)
          .fold(0, (sum, t) => sum + t.amount);

  double totalExpenseForMonth(int month, int year) =>
      getByMonth(month, year)
          .where((t) => t.isExpense)
          .fold(0, (sum, t) => sum + t.amount);

  Map<String, double> expenseByCategory(int month, int year) {
    final map = <String, double>{};
    for (final t in getByMonth(month, year).where((t) => t.isExpense)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  ValueListenable<Box<TransactionModel>> listenable() => _box.listenable();
}