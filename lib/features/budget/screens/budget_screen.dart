import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../cubit/budget_cubit.dart';
import '../../../core/services/notification_service.dart';
import '../widgets/bill_reminder_card.dart';
import '../widgets/budget_item_card.dart';
import '../widgets/budget_overview_card.dart';
import 'add_bill_sheet.dart';
import 'set_budget_sheet.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BudgetCubit(
        BudgetRepository(),
        TransactionRepository(),
        NotificationService(),
      ),
      child: const _BudgetView(),
    );
  }
}

class _BudgetView extends StatefulWidget {
  const _BudgetView();

  @override
  State<_BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<_BudgetView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Budget & Bills',
        actions: [
          BlocBuilder<BudgetCubit, BudgetState>(
            builder: (context, state) {
              if (state is! BudgetLoaded) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _tabCtrl.index == 1
                    ? _showAddBillSheet(context)
                    : null,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator(
                color: AppColors.primary));
          }
          if (state is BudgetError) {
            return Center(child: Text(state.message));
          }
          if (state is! BudgetLoaded) return const SizedBox();

          return Column(
            children: [
              // Overview card
              BudgetOverviewCard(state: state),
              const SizedBox(height: 12),

              // Tab bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: [
                      Tab(text:
                      '📊 Budgets (${state.items.where((i) => i.hasBudget).length})'),
                      Tab(text:
                      '📅 Bills (${state.bills.length})'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    // ── Budgets tab ──────────────────────
                    RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async =>
                          context.read<BudgetCubit>().load(),
                      child: ListView.builder(
                        padding:
                        const EdgeInsets.only(bottom: 100),
                        itemCount: state.items.length,
                        itemBuilder: (_, i) => BudgetItemCard(
                          item:  state.items[i],
                          index: i,
                          onSetBudget: () =>
                              _showSetBudgetSheet(
                                  context, state.items[i]),
                          onDeleteBudget: () =>
                              context.read<BudgetCubit>()
                                  .deleteBudget(
                                  state.items[i].category.id),
                        ),
                      ),
                    ),

                    // ── Bills tab ────────────────────────
                    state.bills.isEmpty
                        ? EmptyState(
                      emoji:    '📅',
                      title:    'No bill reminders',
                      subtitle: 'Add bill reminders so you never miss a payment',
                      action: ElevatedButton.icon(
                        onPressed: () =>
                            _showAddBillSheet(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Bill'),
                      ),
                    )
                        : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async =>
                          context.read<BudgetCubit>().load(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                            bottom: 100),
                        itemCount: state.bills.length,
                        itemBuilder: (_, i) =>
                            BillReminderCard(
                              bill:     state.bills[i],
                              index:    i,
                              onToggle: () =>
                                  context.read<BudgetCubit>()
                                      .toggleBill(state.bills[i]),
                              onDelete: () =>
                                  context.read<BudgetCubit>()
                                      .deleteBill(state.bills[i]),
                              onEdit: () =>
                                  _showAddBillSheet(context,
                                      existing: state.bills[i]),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _AddFAB(tabCtrl: _tabCtrl),
    );
  }

  void _showSetBudgetSheet(BuildContext context, BudgetItem item) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetCubit>(),
        child: SetBudgetSheet(item: item),
      ),
    );
  }

  void _showAddBillSheet(BuildContext context, {dynamic existing}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetCubit>(),
        child: AddBillSheet(existing: existing),
      ),
    );
  }
}

class _AddFAB extends StatelessWidget {
  final TabController tabCtrl;
  const _AddFAB({required this.tabCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabCtrl,
      builder: (_, __) => FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          if (tabCtrl.index == 0) {
            // Scroll to first unset budget
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tap any category to set a budget'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => BlocProvider.value(
                value: context.read<BudgetCubit>(),
                child: const AddBillSheet(),
              ),
            );
          }
        },
        backgroundColor: AppColors.primary,
        icon: Icon(
          tabCtrl.index == 0
              ? Icons.track_changes_rounded
              : Icons.add_rounded,
          color: Colors.white,
        ),
        label: Text(
          tabCtrl.index == 0 ? 'Set Budgets' : 'Add Bill',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    )
        .animate()
        .scale(begin: const Offset(0, 0), end: const Offset(1, 1),
        duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn();
  }
}