import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/account_model.dart';

class AccountCardsRow extends StatelessWidget {
  final List<AccountModel> accounts;

  const AccountCardsRow({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Accounts', style: AppTextStyles.headlineSmall),
              Text('${accounts.length} accounts',
                  style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: accounts.length,
            itemBuilder: (_, i) {
              final acc   = accounts[i];
              final color = Color(acc.colorValue);
              return _AccountCard(
                account: acc,
                color:   color,
                index:   i,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatefulWidget {
  final AccountModel account;
  final Color        color;
  final int          index;

  const _AccountCard({
    required this.account,
    required this.color,
    required this.index,
  });

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  bool _pressed = false;

  String get _emoji {
    switch (widget.account.type) {
      case AccountType.cash:  return '💵';
      case AccountType.bkash: return '📱';
      case AccountType.nagad: return '🟠';
      case AccountType.bank:  return '🏦';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 150,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                widget.color.withOpacity(0.85),
                widget.color,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_emoji,
                      style: const TextStyle(fontSize: 22)),
                  if (widget.account.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Main',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.account.name,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    child: Text(
                      CurrencyFormatter.format(
                          widget.account.balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 + widget.index * 80))
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.15, end: 0, duration: 500.ms,
        curve: Curves.easeOutCubic);
  }
}