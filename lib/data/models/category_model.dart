import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4)
class CategoryModel extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String name;
  @HiveField(2) late String icon;
  @HiveField(3) late int colorValue;
  @HiveField(4) late bool isIncome;
  @HiveField(5) late bool isDefault;

  CategoryModel({
    String? id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.isIncome,
    this.isDefault = false,
  }) {
    this.id = id ?? const Uuid().v4();
  }
}