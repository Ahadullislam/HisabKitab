import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../transactions/widgets/month_selector.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _txRepo   = TransactionRepository();
  final _accRepo  = AccountRepository();
  final _pdfSvc   = PdfService();

  DateTime _month      = DateTime.now();
  bool     _generating = false;

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final txs      = _txRepo.getByMonth(_month.month, _month.year);
    final income   = _txRepo.totalIncomeForMonth(_month.month, _month.year);
    final expense  = _txRepo.totalExpenseForMonth(_month.month, _month.year);
    final balance  = income - expense;
    final accounts = _accRepo.getAll();
    final cats     = Hive.box<CategoryModel>(
        HiveBoxes.categories).values.toList();
    final catExp   = _txRepo.expenseByCategory(_month.month, _month.year);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Month picker
            MonthSelector(
              selectedMonth: _month,
              onChanged:     (m) => setState(() => _month = m),
            ),
            const SizedBox(height: 8),

            // Summary card
            _SummaryCard(
              month:   _month,
              income:  income,
              expense: expense,
              balance: balance,
              txCount: txs.length,
            ).animate().fadeIn(duration: 400.ms)
                .slideY(begin: -0.05, end: 0),

            const SizedBox(height: 16),

            // Top spending
            if (catExp.isNotEmpty) ...[
              Text('Top Spending Categories',
                  style: AppTextStyles.headlineSmall),
              const SizedBox(height: 12),
              ...catExp.entries
                  .map((e) {
                final cat = cats.cast<CategoryModel?>()
                    .firstWhere((c) => c?.id == e.key,
                    orElse: () => null);
                final pct = expense == 0
                    ? 0.0 : (e.value / expense).clamp(0.0, 1.0);
                return _CategoryRow(
                  icon:    cat?.icon ?? '💸',
                  name:    cat?.name ?? 'Other',
                  color:   cat != null
                      ? Color(cat.colorValue) : AppColors.catOther,
                  amount:  e.value,
                  percent: pct,
                );
              })
                  .toList()
                  .take(6)
                  .toList(),
              const SizedBox(height: 16),
            ],

            // Recent transactions preview
            Text('Transactions (${txs.length})',
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            if (txs.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkDivider : AppColors.divider,
                  ),
                ),
                child: const Center(
                  child: Text('No transactions this month',
                      style: TextStyle(color: AppColors.textHint)),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkDivider : AppColors.divider,
                  ),
                ),
                child: Column(
                  children: txs.take(10).map((tx) {
                    final cat = cats.cast<CategoryModel?>()
                        .firstWhere((c) => c?.id == tx.categoryId,
                        orElse: () => null);
                    return ListTile(
                      leading: Text(cat?.icon ?? '💰',
                          style: const TextStyle(fontSize: 22)),
                      title: Text(tx.title,
                          style: AppTextStyles.labelLarge),
                      subtitle: Text(
                          DateFormatter.relative(tx.date),
                          style: AppTextStyles.bodySmall),
                      trailing: Text(
                        '${tx.isIncome ? '+' : '-'}'
                            '${CurrencyFormatter.format(tx.amount)}',
                        style: TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w700,
                          color:      tx.isIncome
                              ? AppColors.income : AppColors.expense,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ).animate(delay: 200.ms).fadeIn(),

            if (txs.length > 10) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '+${txs.length - 10} more in PDF export',
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: 12),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Export buttons
            _ExportButtons(
              generating: _generating,
              onExport: () async {
                HapticFeedback.mediumImpact();
                setState(() => _generating = true);
                try {
                  await _pdfSvc.generateMonthlyReport(
                    context:          context,
                    month:            _month,
                    transactions:     txs,
                    categories:       cats,
                    accounts:         accounts,
                    totalIncome:      income,
                    totalExpense:     expense,
                    expenseByCategory: catExp,
                  );
                } finally {
                  if (mounted) setState(() => _generating = false);
                }
              },
              onPreview: () async {
                HapticFeedback.lightImpact();
                setState(() => _generating = true);
                try {
                  await _pdfSvc.previewReport(
                    context:          context,
                    month:            _month,
                    transactions:     txs,
                    categories:       cats,
                    accounts:         accounts,
                    totalIncome:      income,
                    totalExpense:     expense,
                    expenseByCategory: catExp,
                  );
                } finally {
                  if (mounted) setState(() => _generating = false);
                }
              },
            ).animate(delay: 300.ms)
                .fadeIn()
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Summary Card ─────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final DateTime month;
  final double   income, expense, balance;
  final int      txCount;

  const _SummaryCard({
    required this.month,
    required this.income,
    required this.expense,
    required this.balance,
    required this.txCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3460), Color(0xFF1A56A0)],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:      AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset:     const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormatter.monthYear(month),
                  style: const TextStyle(
                    color:      Colors.white,
                    fontSize:   18,
                    fontWeight: FontWeight.w700,
                  )),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$txCount transactions',
                    style: const TextStyle(
                      color:    Colors.white,
                      fontSize: 12,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _stat('💰 Income',
                  income, Colors.greenAccent)),
              Expanded(child: _stat('💸 Expense',
                  expense, Colors.redAccent.shade100)),
              Expanded(child: _stat(
                balance >= 0 ? '📈 Saved' : '📉 Deficit',
                balance.abs(),
                balance >= 0
                    ? Colors.greenAccent
                    : Colors.redAccent.shade100,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          child: Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Category Row ─────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final String icon, name;
  final Color  color;
  final double amount, percent;

  const _CategoryRow({
    required this.icon,   required this.name,
    required this.color,  required this.amount,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: AppTextStyles.labelLarge),
                    Text(CurrencyFormatter.format(amount),
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: color,
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: percent),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, __) => LinearProgressIndicator(
                      value:           val,
                      minHeight:       6,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor:      AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Export Buttons ────────────────────────────────────────────────
class _ExportButtons extends StatelessWidget {
  final bool          generating;
  final VoidCallback  onExport;
  final VoidCallback  onPreview;

  const _ExportButtons({
    required this.generating,
    required this.onExport,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton.icon(
            onPressed: generating ? null : onExport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: generating
                ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
                : const Icon(Icons.share_rounded,
                color: Colors.white),
            label: Text(
              generating ? 'Generating...' : '📄 Export & Share PDF',
              style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity, height: 54,
          child: OutlinedButton.icon(
            onPressed: generating ? null : onPreview,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.preview_rounded,
                color: AppColors.primary),
            label: const Text('👁 Preview Report',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}