import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/account_model.dart';
import '../cubit/transaction_cubit.dart';

class AddTransactionSheet extends StatefulWidget {
  final TransactionModel? existing;

  const AddTransactionSheet({super.key, this.existing});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _amountCtrl = TextEditingController();
  final _titleCtrl  = TextEditingController();
  final _noteCtrl   = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  CategoryModel? _selectedCategory;
  AccountModel?  _selectedAccount;
  DateTime       _selectedDate = DateTime.now();
  bool           _isIncome     = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() {
          _isIncome = _tabCtrl.index == 1;
          _selectedCategory = null;
        });
      }
    });

    if (widget.existing != null) {
      final tx = widget.existing!;
      _amountCtrl.text  = tx.amount.toString();
      _titleCtrl.text   = tx.title;
      _noteCtrl.text    = tx.note;
      _selectedDate     = tx.date;
      _isIncome         = tx.isIncome;
      _tabCtrl.index    = tx.isIncome ? 1 : 0;
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) {
          return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()));
        }

        final categories = state.categories
            .where((c) => c.isIncome == _isIncome)
            .toList();
        final accounts = state.accounts;

        _selectedAccount ??= widget.existing != null
            ? accounts.firstWhere(
                (a) => a.id == widget.existing!.accountId,
            orElse: () => accounts.first)
            : accounts.first;

        if (widget.existing != null && _selectedCategory == null) {
          try {
            _selectedCategory = categories.firstWhere(
                    (c) => c.id == widget.existing!.categoryId);
          } catch (_) {}
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Tab bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                    tabs: const [
                      Tab(text: '💸  Expense'),
                      Tab(text: '💰  Income'),
                    ],
                  ),
                ),
              ),
              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20, 20, 20,
                    MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Amount
                        _label('Amount'),
                        TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: _isIncome
                                ? AppColors.income : AppColors.expense,
                          ),
                          decoration: InputDecoration(
                            prefixText: '৳ ',
                            prefixStyle: AppTextStyles.headlineLarge.copyWith(
                              color: _isIncome
                                  ? AppColors.income : AppColors.expense,
                            ),
                            hintText: '0.00',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter an amount';
                            }
                            if (double.tryParse(v) == null ||
                                double.parse(v) <= 0) {
                              return 'Enter a valid amount';
                            }
                            return null;
                          },
                          autofocus: widget.existing == null,
                        ).animate().fadeIn(duration: 300.ms)
                            .slideY(begin: 0.05, end: 0),
                        const SizedBox(height: 16),

                        // Title
                        _label('Title'),
                        TextFormField(
                          controller: _titleCtrl,
                          textCapitalization:
                          TextCapitalization.sentences,
                          decoration: const InputDecoration(
                              hintText: 'e.g. Lunch at restaurant'),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter a title' : null,
                        ),
                        const SizedBox(height: 16),

                        // Category
                        _label('Category'),
                        _CategoryPicker(
                          categories: categories,
                          selected: _selectedCategory,
                          onSelect: (c) =>
                              setState(() => _selectedCategory = c),
                        ),
                        const SizedBox(height: 16),

                        // Account
                        _label('Account'),
                        _AccountPicker(
                          accounts: accounts,
                          selected: _selectedAccount!,
                          onSelect: (a) =>
                              setState(() => _selectedAccount = a),
                        ),
                        const SizedBox(height: 16),

                        // Date
                        _label('Date'),
                        _DatePicker(
                          selected: _selectedDate,
                          onSelect: (d) =>
                              setState(() => _selectedDate = d),
                        ),
                        const SizedBox(height: 16),

                        // Note
                        _label('Note (optional)'),
                        TextFormField(
                          controller: _noteCtrl,
                          maxLines: 2,
                          textCapitalization:
                          TextCapitalization.sentences,
                          decoration: const InputDecoration(
                              hintText: 'Add a note...'),
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => _save(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isIncome
                                  ? AppColors.income : AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              widget.existing != null
                                  ? 'Update Transaction'
                                  : 'Save Transaction',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppTextStyles.labelLarge),
  );

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final tx = TransactionModel(
      id: widget.existing?.id,
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text),
      type: _isIncome
          ? TransactionType.income : TransactionType.expense,
      categoryId: _selectedCategory!.id,
      accountId:  _selectedAccount!.id,
      date:       _selectedDate,
      note:       _noteCtrl.text.trim(),
    );

    final cubit = context.read<TransactionCubit>();
    if (widget.existing != null) {
      await cubit.updateTransaction(widget.existing!, tx);
    } else {
      await cubit.addTransaction(tx);
    }

    if (context.mounted) Navigator.pop(context);
  }
}

// ── Category Picker ──────────────────────────────────────────────
class _CategoryPicker extends StatelessWidget {
  final List<CategoryModel> categories;
  final CategoryModel?      selected;
  final ValueChanged<CategoryModel> onSelect;

  const _CategoryPicker({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = selected?.id == cat.id;
          return GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); onSelect(cat); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(cat.colorValue).withOpacity(0.15)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Color(cat.colorValue) : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat.icon,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(cat.name,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? Color(cat.colorValue)
                            : AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          ).animate(delay: Duration(milliseconds: i * 30))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

// ── Account Picker ───────────────────────────────────────────────
class _AccountPicker extends StatelessWidget {
  final List<AccountModel> accounts;
  final AccountModel       selected;
  final ValueChanged<AccountModel> onSelect;

  const _AccountPicker({
    required this.accounts,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: accounts.map((acc) {
        final isSelected = selected.id == acc.id;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(acc);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(_accountEmoji(acc.type),
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(acc.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _accountEmoji(AccountType t) {
    switch (t) {
      case AccountType.cash:  return '💵';
      case AccountType.bkash: return '📱';
      case AccountType.nagad: return '🟠';
      case AccountType.bank:  return '🏦';
    }
  }
}

// ── Date Picker ──────────────────────────────────────────────────
class _DatePicker extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const _DatePicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selected,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              selected.day == DateTime.now().day &&
                  selected.month == DateTime.now().month &&
                  selected.year == DateTime.now().year
                  ? 'Today'
                  : '${selected.day}/${selected.month}/${selected.year}',
              style: AppTextStyles.bodyLarge,
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}