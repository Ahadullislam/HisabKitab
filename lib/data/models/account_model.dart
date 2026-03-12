import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'account_model.g.dart';

@HiveType(typeId: 2)
enum AccountType {
  @HiveField(0) cash,
  @HiveField(1) bkash,
  @HiveField(2) nagad,
  @HiveField(3) bank,
}

@HiveType(typeId: 3)
class AccountModel extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String name;
  @HiveField(2) late AccountType type;
  @HiveField(3) late double balance;
  @HiveField(4) late int colorValue;
  @HiveField(5) late bool isDefault;

  AccountModel({
    String? id,
    required this.name,
    required this.type,
    required this.balance,
    required this.colorValue,
    this.isDefault = false,
  }) {
    this.id = id ?? const Uuid().v4();
  }

  AccountModel copyWith({
    String? name,
    AccountType? type,
    double? balance,
    int? colorValue,
    bool? isDefault,
  }) => AccountModel(
    id:         id,
    name:       name       ?? this.name,
    type:       type       ?? this.type,
    balance:    balance    ?? this.balance,
    colorValue: colorValue ?? this.colorValue,
    isDefault:  isDefault  ?? this.isDefault,
  );
}