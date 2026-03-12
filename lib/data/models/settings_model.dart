class AppSettings {
  final bool   biometricEnabled;
  final bool   pinEnabled;
  final String pin;
  final bool   darkMode;
  final bool   hideBalance;
  final String currencySymbol;

  const AppSettings({
    this.biometricEnabled = false,
    this.pinEnabled       = false,
    this.pin              = '',
    this.darkMode         = false,
    this.hideBalance      = false,
    this.currencySymbol   = '৳',
  });

  AppSettings copyWith({
    bool?   biometricEnabled,
    bool?   pinEnabled,
    String? pin,
    bool?   darkMode,
    bool?   hideBalance,
    String? currencySymbol,
  }) => AppSettings(
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    pinEnabled:       pinEnabled       ?? this.pinEnabled,
    pin:              pin              ?? this.pin,
    darkMode:         darkMode         ?? this.darkMode,
    hideBalance:      hideBalance      ?? this.hideBalance,
    currencySymbol:   currencySymbol   ?? this.currencySymbol,
  );

  Map<String, dynamic> toMap() => {
    'biometricEnabled': biometricEnabled,
    'pinEnabled':       pinEnabled,
    'pin':              pin,
    'darkMode':         darkMode,
    'hideBalance':      hideBalance,
    'currencySymbol':   currencySymbol,
  };

  factory AppSettings.fromMap(Map map) => AppSettings(
    biometricEnabled: map['biometricEnabled'] ?? false,
    pinEnabled:       map['pinEnabled']       ?? false,
    pin:              map['pin']              ?? '',
    darkMode:         map['darkMode']         ?? false,
    hideBalance:      map['hideBalance']      ?? false,
    currencySymbol:   map['currencySymbol']   ?? '৳',
  );
}