import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/lock_service.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/repositories/settings_repository.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/pin_setup_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(
          SettingsRepository(), LockService()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator(
                color: AppColors.primary));
          }
          final s    = state.settings;
          final cubit = context.read<SettingsCubit>();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // ── Security section ───────────────────────
              _sectionHeader('🔐  Security'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon:     Icons.pin_rounded,
                    iconColor: AppColors.primary,
                    title:    'PIN Lock',
                    subtitle: s.pinEnabled
                        ? 'PIN is enabled — tap to change'
                        : 'Protect app with a 4-digit PIN',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (s.pinEnabled)
                          TextButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              cubit.removePin();
                            },
                            child: const Text('Remove',
                                style: TextStyle(
                                    color: AppColors.expense)),
                          ),
                        Switch(
                          value:     s.pinEnabled,
                          onChanged: (_) => _showPinSetup(
                              context, cubit, s.pin),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  if (s.pinEnabled) ...[
                    const Divider(height: 1),
                    _SettingsTile(
                      icon:      Icons.fingerprint_rounded,
                      iconColor: AppColors.income,
                      title:    'Biometric Unlock',
                      subtitle: state.biometricAvailable
                          ? 'Use fingerprint to unlock'
                          : 'Not available on this device',
                      trailing: Switch(
                        value:     s.biometricEnabled,
                        onChanged: state.biometricAvailable
                            ? (_) => cubit.toggleBiometric()
                            : null,
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ).animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: 8),

              // ── Display section ────────────────────────
              _sectionHeader('🎨  Display'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon:      Icons.dark_mode_rounded,
                    iconColor: AppColors.primaryDark,
                    title:    'Dark Mode',
                    subtitle: 'Switch between light and dark theme',
                    trailing: Switch(
                      value:     s.darkMode,
                      onChanged: (_) => cubit.toggleDarkMode(),
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon:      Icons.visibility_off_rounded,
                    iconColor: AppColors.warning,
                    title:    'Hide Balance',
                    subtitle: 'Mask amounts on dashboard',
                    trailing: Switch(
                      value:     s.hideBalance,
                      onChanged: (_) => cubit.toggleHideBalance(),
                      activeColor: AppColors.primary,
                    ),
                  ),
                ],
              ).animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: 8),

              // ── Data section ───────────────────────────
              _sectionHeader('📊  Data'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon:      Icons.picture_as_pdf_rounded,
                    iconColor: AppColors.expense,
                    title:    'Export PDF Report',
                    subtitle: 'Generate monthly financial report',
                    onTap:    () => context.go_to_reports(),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon:      Icons.cloud_upload_rounded,
                    iconColor: AppColors.primary,
                    title:    'Cloud Backup',
                    subtitle: 'Coming in Phase 6',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Soon',
                        style: TextStyle(
                          fontSize:   11,
                          fontWeight: FontWeight.w700,
                          color:      AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: 8),

              // ── About section ──────────────────────────
              _sectionHeader('ℹ️  About'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon:      Icons.info_outline_rounded,
                    iconColor: AppColors.textSecondary,
                    title:    'HishabKitab',
                    subtitle: 'Version 1.0.0  •  Made with ❤️ in Bangladesh',
                    onTap:    () {},
                  ),
                ],
              ).animate(delay: 400.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 0, 6),
    child: Text(title,
      style: const TextStyle(
        fontSize:   12,
        fontWeight: FontWeight.w700,
        color:      AppColors.textHint,
        letterSpacing: 0.5,
      ),
    ),
  );

  void _showPinSetup(
      BuildContext context,
      SettingsCubit cubit,
      String existingPin) {
    if (existingPin.isNotEmpty) {
      // Toggle off — already handled by removePin button
      return;
    }
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PinSetupSheet(
        existingPin: existingPin.isEmpty ? null : existingPin,
        onPinSet:    (pin) => cubit.setPin(pin),
      ),
    );
  }
}

extension on BuildContext {
  void go_to_reports() {
    // Will be wired to reports screen in Phase 6
    ScaffoldMessenger.of(this).showSnackBar(
      const SnackBar(
        content: Text('PDF Export coming in Reports screen!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   title;
  final String   subtitle;
  final Widget?  trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap:        onTap,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 4),
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title:    Text(title, style: AppTextStyles.labelLarge),
      subtitle: Text(subtitle, style: AppTextStyles.bodyMedium),
      trailing: trailing,
    );
  }
}