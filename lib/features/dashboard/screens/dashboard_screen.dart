import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/account_cards_row.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/recent_transactions_preview.dart';
import '../widgets/savings_rate_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(
        AccountRepository(),
        TransactionRepository(),
      ),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return _buildShimmer(context);
          }
          if (state is DashboardError) {
            return Center(child: Text(state.message));
          }
          if (state is! DashboardLoaded) return const SizedBox();

          return RefreshIndicator(
            color:     AppColors.primary,
            onRefresh: () async =>
                context.read<DashboardCubit>().load(),
            child: CustomScrollView(
              slivers: [
                // ── App Bar ──────────────────────────────────
                SliverAppBar(
                  floating:       true,
                  snap:           true,
                  backgroundColor: Theme.of(context)
                      .scaffoldBackgroundColor,
                  surfaceTintColor: Colors.transparent,
                  title: Row(
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('৳',
                            style: TextStyle(
                              color:      Colors.white,
                              fontSize:   18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('HishabKitab',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize:   20,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                          Icons.notifications_outlined),
                      onPressed: () =>
                          HapticFeedback.lightImpact(),
                    ),
                  ],
                ),

                // ── Body ─────────────────────────────────────
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // Balance hero
                    BalanceHeroCard(
                      totalBalance:   state.totalBalance,
                      monthlyIncome:  state.monthlyIncome,
                      monthlyExpense: state.monthlyExpense,
                      month:          state.selectedMonth,
                    ),

                    // Account cards
                    AccountCardsRow(accounts: state.accounts),

                    // Monthly bar chart
                    _sectionCard(
                      context: context,
                      title:   'Income vs Expense',
                      child:   MonthlyBarChart(
                          data: state.monthlyData),
                    ),

                    // Expense pie chart
                    _sectionCard(
                      context: context,
                      title:   'Spending by Category',
                      child:   ExpensePieChart(
                          data: state.catBreakdown),
                    ),

                    // Savings rate
                    SavingsRateCard(
                        savingsRate: state.savingsRate, income: state.monthlyIncome, expense: state.monthlyExpense,),

                    // Recent transactions
                    RecentTransactionsPreview(
                      transactions: state.recentTx,
                      categories:   state.categories,
                    ),

                    const SizedBox(height: 100),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String       title,
    required Widget       child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.04, end: 0, duration: 500.ms,
        curve: Curves.easeOutCubic);
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor:      isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 60),
          _shimmerBox(200),
          const SizedBox(height: 12),
          _shimmerBox(100),
          const SizedBox(height: 12),
          _shimmerBox(220),
          const SizedBox(height: 12),
          _shimmerBox(180),
        ],
      ),
    );
  }

  Widget _shimmerBox(double height) => Container(
    height: height,
    margin: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
  );
}