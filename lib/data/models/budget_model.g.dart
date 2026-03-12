// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = 5;

  @override
  BudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetModel(
      id: fields[0] as String?,
      categoryId: fields[1] as String,
      limitAmount: fields[2] as double,
      month: fields[3] as int,
      year: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.limitAmount)
      ..writeByte(3)
      ..write(obj.month)
      ..writeByte(4)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillReminderModelAdapter extends TypeAdapter<BillReminderModel> {
  @override
  final int typeId = 6;

  @override
  BillReminderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillReminderModel(
      id: fields[0] as String?,
      title: fields[1] as String,
      amount: fields[2] as double,
      dayOfMonth: fields[3] as int,
      colorValue: fields[4] as int,
      icon: fields[5] as String,
      categoryId: fields[7] as String,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BillReminderModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.dayOfMonth)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.icon)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.categoryId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillReminderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
