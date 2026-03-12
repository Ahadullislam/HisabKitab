import 'package:hive_flutter/hive_flutter.dart';
import '../local/hive_boxes.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  Box get _box => Hive.box(HiveBoxes.settings);

  AppSettings load() {
    final map = _box.get('settings');
    if (map == null) return const AppSettings();
    return AppSettings.fromMap(Map.from(map));
  }

  Future<void> save(AppSettings settings) async =>
      _box.put('settings', settings.toMap());
}