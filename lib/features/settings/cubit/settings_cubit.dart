import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/lock_service.dart';
import '../../../data/models/settings_model.dart';
import '../../../data/repositories/settings_repository.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repo;
  final LockService        _lockService;

  SettingsCubit(this._repo, this._lockService)
      : super(SettingsInitial()) {
    load();
  }

  Future<void> load() async {
    final settings = _repo.load();
    final biometricAvailable =
    await _lockService.isBiometricAvailable();
    emit(SettingsLoaded(
        settings: settings,
        biometricAvailable: biometricAvailable));
  }

  Future<void> toggleBiometric() async {
    final state = this.state;
    if (state is! SettingsLoaded) return;

    if (!state.settings.biometricEnabled) {
      // Test auth before enabling
      final result = await _lockService.authenticate(
        reason: 'Enable biometric lock for HishabKitab',
      );
      if (result != LockResult.success) return;
    }

    final updated = state.settings.copyWith(
      biometricEnabled: !state.settings.biometricEnabled,
    );
    await _repo.save(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> setPin(String pin) async {
    final state = this.state;
    if (state is! SettingsLoaded) return;

    final updated = state.settings.copyWith(
      pinEnabled: true,
      pin: pin,
    );
    await _repo.save(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> removePin() async {
    final state = this.state;
    if (state is! SettingsLoaded) return;

    final updated = state.settings.copyWith(
      pinEnabled:       false,
      pin:              '',
      biometricEnabled: false,
    );
    await _repo.save(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> toggleHideBalance() async {
    final state = this.state;
    if (state is! SettingsLoaded) return;

    final updated = state.settings.copyWith(
      hideBalance: !state.settings.hideBalance,
    );
    await _repo.save(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> toggleDarkMode() async {
    final state = this.state;
    if (state is! SettingsLoaded) return;

    final updated = state.settings.copyWith(
      darkMode: !state.settings.darkMode,
    );
    await _repo.save(updated);
    emit(state.copyWith(settings: updated));
  }
}