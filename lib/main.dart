import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/lock_service.dart';
import 'data/local/hive_boxes.dart';
import 'data/local/seed_data.dart';
import 'data/models/transaction_model.dart';
import 'data/models/account_model.dart';
import 'data/models/category_model.dart';
import 'data/models/budget_model.dart';
import 'data/models/settings_model.dart';
import 'data/repositories/account_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'features/lock/lock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(AccountTypeAdapter());
  Hive.registerAdapter(AccountModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(BillReminderModelAdapter());

  // Open boxes
  await Hive.openBox<TransactionModel>(HiveBoxes.transactions);
  await Hive.openBox<AccountModel>(HiveBoxes.accounts);
  await Hive.openBox<CategoryModel>(HiveBoxes.categories);
  await Hive.openBox<BudgetModel>(HiveBoxes.budgets);
  await Hive.openBox<BillReminderModel>(HiveBoxes.billReminders);
  await Hive.openBox(HiveBoxes.settings);

  // Init notifications
  await NotificationService().init();

  // Seed default data on first run
  await _seedIfEmpty();

  runApp(const LockGate());
}

Future<void> _seedIfEmpty() async {
  final accountRepo = AccountRepository();
  final txRepo      = TransactionRepository();

  if (accountRepo.getAll().isEmpty) {
    for (final a in SeedData.defaultAccounts) {
      await accountRepo.add(a);
    }
  }

  if (txRepo.getAll().isEmpty) {
    final catBox = Hive.box<CategoryModel>(HiveBoxes.categories);
    if (catBox.isEmpty) {
      for (final c in SeedData.defaultCategories) {
        catBox.put(c.id, c);
      }
    }
  }
}

// ── Main App ──────────────────────────────────────────────────────
class HishabKitabApp extends StatelessWidget {
  const HishabKitabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title:                   'Hishab Kitab',
      debugShowCheckedModeBanner: false,
      theme:        AppTheme.light,
      darkTheme:    AppTheme.dark,
      themeMode:    ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}

// ── Lock Gate — wraps the entire app ─────────────────────────────
class LockGate extends StatefulWidget {
  const LockGate({super.key});

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate>
    with WidgetsBindingObserver {
  final _settingsRepo = SettingsRepository();
  bool         _locked   = false;
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settings = _settingsRepo.load();
    _locked   = _settings.pinEnabled || _settings.biometricEnabled;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-lock when app goes to background
    if (state == AppLifecycleState.paused) {
      final s = _settingsRepo.load();
      if (s.pinEnabled || s.biometricEnabled) {
        setState(() {
          _locked   = true;
          _settings = s;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme:     AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: LockScreen(
          biometricEnabled: _settings.biometricEnabled,
          pinEnabled:       _settings.pinEnabled,
          savedPin:         _settings.pin,
          onUnlocked:       () => setState(() => _locked = false),
        ),
      );
    }
    return const HishabKitabApp();
  }
}