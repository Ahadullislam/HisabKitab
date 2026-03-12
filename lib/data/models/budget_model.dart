import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 5)
class BudgetModel extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String categoryId;
  @HiveField(2) late double limitAmount;
  @HiveField(3) late int    month;
  @HiveField(4) late int    year;

  BudgetModel({
    String? id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
  }) {
    this.id = id ?? const Uuid().v4();
  }

  BudgetModel copyWith({
    String? categoryId,
    double? limitAmount,
    int?    month,
    int?    year,
  }) => BudgetModel(
    id:          id,
    categoryId:  categoryId  ?? this.categoryId,
    limitAmount: limitAmount ?? this.limitAmount,
    month:       month       ?? this.month,
    year:        year        ?? this.year,
  );
}

// ── Bill Reminder model ──────────────────────────────────────────
@HiveType(typeId: 6)
class BillReminderModel extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String title;
  @HiveField(2) late double amount;
  @HiveField(3) late int    dayOfMonth;   // 1-28
  @HiveField(4) late int    colorValue;
  @HiveField(5) late String icon;
  @HiveField(6) late bool   isActive;
  @HiveField(7) late String categoryId;

  BillReminderModel({
    String? id,
    required this.title,
    required this.amount,
    required this.dayOfMonth,
    required this.colorValue,
    required this.icon,
    required this.categoryId,
    this.isActive = true,
  }) {
    this.id = id ?? const Uuid().v4();
  }

  BillReminderModel copyWith({
    String? title,
    double? amount,
    int?    dayOfMonth,
    int?    colorValue,
    String? icon,
    String? categoryId,
    bool?   isActive,
  }) => BillReminderModel(
    id:          id,
    title:       title       ?? this.title,
    amount:      amount      ?? this.amount,
    dayOfMonth:  dayOfMonth  ?? this.dayOfMonth,
    colorValue:  colorValue  ?? this.colorValue,
    icon:        icon        ?? this.icon,
    categoryId:  categoryId  ?? this.categoryId,
    isActive:    isActive    ?? this.isActive,
  );

  DateTime nextDueDate() {
    final now = DateTime.now();
    var due = DateTime(now.year, now.month, dayOfMonth);
    if (due.isBefore(now)) {
      due = DateTime(now.year, now.month + 1, dayOfMonth);
    }
    return due;
  }

  int get daysUntilDue {
    final diff = nextDueDate().difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }
}