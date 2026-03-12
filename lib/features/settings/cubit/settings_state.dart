part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;
  final bool        biometricAvailable;

  const SettingsLoaded({
    required this.settings,
    required this.biometricAvailable,
  });

  SettingsLoaded copyWith({
    AppSettings? settings,
    bool?        biometricAvailable,
  }) => SettingsLoaded(
    settings:           settings           ?? this.settings,
    biometricAvailable: biometricAvailable ?? this.biometricAvailable,
  );

  @override
  List<Object?> get props => [settings, biometricAvailable];
}