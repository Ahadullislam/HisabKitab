import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/account_repository.dart';
import '../cubit/transaction_cubit.dart';
import '../widgets/month_selector.dart';
import '../widgets/summary_bar.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_sheet.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionCubit(
        TransactionRepository(),
        AccountRepository(),
      ),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Transactions',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: _AddFAB(),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return _buildSkeleton();
          }
          if (state is TransactionError) {
            return Center(child: Text(state.message));
          }
          if (state is! TransactionLoaded) {
            return const SizedBox();
          }

          return Column(
            children: [
              MonthSelector(
                selectedMonth: state.selectedMonth,
                onChanged: (m) =>
                    context.read<TransactionCubit>().changeMonth(m),
              ),
              SummaryBar(
                  income: state.totalIncome,
                  expense: state.totalExpense),
              const SizedBox(height: 8),
              Expanded(
                child: state.transactions.isEmpty
                    ? EmptyState(
                  emoji: '📭',
                  title: 'No transactions yet',
                  subtitle:
                  'Tap the + button to add your first transaction',
                  action: ElevatedButton.icon(
                    onPressed: () =>
                        _showAddSheet(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Transaction'),
                  ),
                )
                    : _buildGroupedList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupedList(
      BuildContext context, TransactionLoaded state) {
    // Group by date
    final grouped = <String, List<int>>{};
    for (int i = 0; i < state.transactions.length; i++) {
      final tx = state.transactions[i];
      final key =
          '${tx.date.year}-${tx.date.month}-${tx.date.day}';
      grouped.putIfAbsent(key, () => []).add(i);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: grouped.length,
      itemBuilder: (_, gi) {
        final dateKey = grouped.keys.elementAt(gi);
        final indices = grouped[dateKey]!;
        final date    = state.transactions[indices.first].date;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateHeader(date: date, index: gi),
            ...indices.map((i) {
              final tx  = state.transactions[i];
              final cat = state.categories.cast<dynamic>()
                  .firstWhere(
                      (c) => c.id == tx.categoryId,
                  orElse: () => null);
              final acc = state.accounts.cast<dynamic>()
                  .firstWhere(
                      (a) => a.id == tx.accountId,
                  orElse: () => null);
              return TransactionTile(
                transaction: tx,
                category:    cat,
                account:     acc,
                index:       i,
                onEdit:      () => _showAddSheet(
                    context, existing: tx),
                onDelete: () => context
                    .read<TransactionCubit>()
                    .deleteTransaction(tx),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        height: 72,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(16),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1200.ms, color: Colors.white38),
    );
  }

  void _showAddSheet(BuildContext context,
      {dynamic existing}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionCubit>(),
        child: AddTransactionSheet(existing: existing),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final int index;
  const _DateHeader({required this.date, required this.index});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month && date.day == now.day;
    final isYesterday = date.year == now.year &&
        date.month == now.month && date.day == now.day - 1;

    final label = isToday ? 'Today'
        : isYesterday ? 'Yesterday'
        : '${date.day} ${_month(date.month)}';

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textHint,
              letterSpacing: 0.8)),
    ).animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 300.ms);
  }

  String _month(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m];
}

class _AddFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => BlocProvider.value(
            value: context.read<TransactionCubit>(),
            child: const AddTransactionSheet(),
          ),
        );
      },
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text('Add',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700)),
    )
        .animate()
        .scale(begin: const Offset(0, 0), end: const Offset(1, 1),
        duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 300.ms);
  }
}