import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(AppRouter.transactions)) return 1;
    if (location.startsWith(AppRouter.accounts))     return 2;
    if (location.startsWith(AppRouter.budget))       return 3;
    if (location.startsWith(AppRouter.settings))     return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    HapticFeedback.lightImpact();
    switch (index) {
      case 0: context.go(AppRouter.dashboard);    break;
      case 1: context.go(AppRouter.transactions); break;
      case 2: context.go(AppRouter.accounts);     break;
      case 3: context.go(AppRouter.budget);       break;
      case 4: context.go(AppRouter.settings);     break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index    = _locationToIndex(location);
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20, offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(5, (i) {
                final selected = i == index;
                final items = [
                  _NavItem(icon: _NavIcons.home(selected),     label: 'Home'),
                  _NavItem(icon: _NavIcons.transactions(selected), label: 'Txns'),
                  _NavItem(icon: _NavIcons.accounts(selected), label: 'Wallet'),
                  _NavItem(icon: _NavIcons.budget(selected),   label: 'Budget'),
                  _NavItem(icon: _NavIcons.settings(selected), label: 'Settings'),
                ];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTap(context, i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            padding: EdgeInsets.all(selected ? 8 : 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AnimatedScale(
                              scale: selected ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                items[i].icon,
                                color: selected
                                    ? AppColors.primary
                                    : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textHint),
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w700 : FontWeight.w400,
                              color: selected
                                  ? AppColors.primary
                                  : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textHint),
                            ),
                            child: Text(items[i].label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavIcons {
  static IconData home(bool s)         => s ? Icons.home_rounded         : Icons.home_outlined;
  static IconData transactions(bool s) => s ? Icons.receipt_long_rounded : Icons.receipt_long_outlined;
  static IconData accounts(bool s)     => s ? Icons.account_balance_wallet_rounded
      : Icons.account_balance_wallet_outlined;
  static IconData budget(bool s)       => s ? Icons.pie_chart_rounded    : Icons.pie_chart_outline_rounded;
  static IconData settings(bool s)     => s ? Icons.settings_rounded     : Icons.settings_outlined;
}