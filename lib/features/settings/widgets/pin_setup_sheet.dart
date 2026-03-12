import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class PinSetupSheet extends StatefulWidget {
  final String? existingPin;
  final ValueChanged<String> onPinSet;

  const PinSetupSheet({
    super.key,
    this.existingPin,
    required this.onPinSet,
  });

  @override
  State<PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends State<PinSetupSheet> {
  static const _len = 4;

  String _pin        = '';
  String _confirmPin = '';
  bool   _confirming = false;
  bool   _hasError   = false;

  void _onDigit(String d) {
    HapticFeedback.selectionClick();
    if (!_confirming) {
      if (_pin.length < _len) {
        setState(() { _pin += d; _hasError = false; });
        if (_pin.length == _len) {
          setState(() => _confirming = true);
        }
      }
    } else {
      if (_confirmPin.length < _len) {
        setState(() { _confirmPin += d; _hasError = false; });
        if (_confirmPin.length == _len) {
          _validate();
        }
      }
    }
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    if (_confirming) {
      if (_confirmPin.isNotEmpty) {
        setState(() => _confirmPin =
            _confirmPin.substring(0, _confirmPin.length - 1));
      } else {
        setState(() { _confirming = false; _pin = ''; });
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() =>
        _pin = _pin.substring(0, _pin.length - 1));
      }
    }
  }

  void _validate() {
    if (_pin == _confirmPin) {
      HapticFeedback.heavyImpact();
      widget.onPinSet(_pin);
      Navigator.pop(context);
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _hasError   = true;
        _confirmPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _confirming ? _confirmPin : _pin;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 44, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _confirming ? 'Confirm your PIN' : 'Create a 4-digit PIN',
              key: ValueKey(_confirming),
              style: AppTextStyles.headlineMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _confirming
                ? 'Enter the same PIN again'
                : 'This PIN protects your financial data',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_len, (i) {
              final filled = i < current.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve:    Curves.easeOutBack,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width:  filled ? 18 : 14,
                height: filled ? 18 : 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hasError
                      ? AppColors.expense
                      : filled
                      ? AppColors.primary
                      : AppColors.divider,
                  boxShadow: filled && !_hasError ? [
                    BoxShadow(
                      color:      AppColors.primary.withOpacity(0.35),
                      blurRadius: 8,
                    ),
                  ] : null,
                ),
              );
            }),
          ),
          if (_hasError) ...[
            const SizedBox(height: 12),
            Text("PINs don't match. Try again.",
                style: TextStyle(
                    color: AppColors.expense, fontSize: 13)),
          ],
          const SizedBox(height: 32),

          // Numpad
          Column(
            children: [
              _row(['1', '2', '3']),
              const SizedBox(height: 14),
              _row(['4', '5', '6']),
              const SizedBox(height: 14),
              _row(['7', '8', '9']),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 68),
                  _digitBtn('0'),
                  GestureDetector(
                    onTap: _onDelete,
                    child: const SizedBox(
                      width: 68, height: 56,
                      child: Center(
                        child: Icon(
                            Icons.backspace_outlined,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(List<String> ds) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: ds.map(_digitBtn).toList(),
  );

  Widget _digitBtn(String d) => GestureDetector(
    onTap: () => _onDigit(d),
    child: Container(
      width: 68, height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(d,
          style: const TextStyle(
            fontSize:   24,
            fontWeight: FontWeight.w400,
            color:      AppColors.textPrimary,
          ),
        ),
      ),
    ),
  );
}