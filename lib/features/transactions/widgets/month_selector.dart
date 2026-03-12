import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = selectedMonth.year == now.year &&
        selectedMonth.month == now.month;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _arrow(context, Icons.chevron_left_rounded, () {
            HapticFeedback.selectionClick();
            onChanged(DateTime(
                selectedMonth.year, selectedMonth.month - 1));
          }),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showMonthPicker(context),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                DateFormatter.monthYear(selectedMonth),
                key: ValueKey(selectedMonth),
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _arrow(context, Icons.chevron_right_rounded, isCurrentMonth
              ? null
              : () {
            HapticFeedback.selectionClick();
            onChanged(DateTime(
                selectedMonth.year, selectedMonth.month + 1));
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _arrow(BuildContext ctx, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: onTap != null
                ? AppColors.primary
                : AppColors.textHint,
            size: 22),
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MonthPickerSheet(
        selected: selectedMonth,
        onPick: (d) { Navigator.pop(context); onChanged(d); },
      ),
    );
  }
}

class _MonthPickerSheet extends StatefulWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onPick;
  const _MonthPickerSheet({required this.selected, required this.onPick});

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.selected.year;
  }

  @override
  Widget build(BuildContext context) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => setState(() => _year--),
              ),
              Text('$_year', style: AppTextStyles.headlineMedium),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _year < DateTime.now().year
                    ? () => setState(() => _year++) : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, childAspectRatio: 2,
              crossAxisSpacing: 8, mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (_, i) {
              final isSelected = _year == widget.selected.year &&
                  (i + 1) == widget.selected.month;
              final isFuture = DateTime(_year, i + 1)
                  .isAfter(DateTime.now());
              return GestureDetector(
                onTap: isFuture ? null : () =>
                    widget.onPick(DateTime(_year, i + 1)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(months[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isSelected ? Colors.white
                            : isFuture ? AppColors.textHint
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}