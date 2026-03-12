import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/account_model.dart';
import '../local/hive_boxes.dart';

class AccountRepository {
  Box<AccountModel> get _box =>
      Hive.box<AccountModel>(HiveBoxes.accounts);

  List<AccountModel> getAll() => _box.values.toList();

  AccountModel? getById(String id) => _box.get(id);

  AccountModel? get defaultAccount =>
      _box.values.firstWhere((a) => a.isDefault,
          orElse: () => _box.values.first);

  Future<void> add(AccountModel a)    async => _box.put(a.id, a);
  Future<void> update(AccountModel a) async => _box.put(a.id, a);
  Future<void> delete(String id)      async => _box.delete(id);

  double get totalBalance =>
      _box.values.fold(0, (sum, a) => sum + a.balance);

  Future<void> updateBalance(String id, double delta) async {
    final account = getById(id);
    if (account != null) {
      await update(account.copyWith(balance: account.balance + delta));
    }
  }

  ValueListenable<Box<AccountModel>> listenable() => _box.listenable();
}