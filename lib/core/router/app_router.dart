import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/transactions/screens/transactions_screen.dart';
import '../../features/accounts/screens/accounts_screen.dart';
import '../../features/budget/screens/budget_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/reports/screens/reports_screen.dart';

class AppRouter {
  AppRouter._();

  static const dashboard    = '/';
  static const transactions = '/transactions';
  static const accounts     = '/accounts';
  static const budget       = '/budget';
  static const settings     = '/settings';
  static const reports = '/reports';

  static final router = GoRouter(
    initialLocation: dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: dashboard,
              builder: (c, s) => const DashboardScreen()),
          GoRoute(path: transactions,
              builder: (c, s) => const TransactionsScreen()),
          GoRoute(path: accounts,
              builder: (c, s) => const AccountsScreen()),
          GoRoute(path: budget,
              builder: (c, s) => const BudgetScreen()),
          GoRoute(path: settings,
              builder: (c, s) => const SettingsScreen()),
          GoRoute(path: reports,
              builder: (c, s) => const ReportsScreen()),
        ],
      ),
    ],
  );
}