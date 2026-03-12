import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/lock_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final bool         biometricEnabled;
  final bool         pinEnabled;
  final String       savedPin;

  const LockScreen({
    super.key,
    required this.onUnlocked,
    required this.biometricEnabled,
    required this.pinEnabled,
    required this.savedPin,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  final _lockService = LockService();
  String  _enteredPin = '';
  bool    _hasError   = false;
  bool    _isLoading  = false;
  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeAnim;

  static const _pinLength = 4;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    if (widget.biometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback(
              (_) => _tryBiometric());
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    setState(() => _isLoading = true);
    final result = await _lockService.authenticate(
      reason: 'Unlock HishabKitab',
    );
    setState(() => _isLoading = false);
    if (result == LockResult.success) {
      widget.onUnlocked();
    }
  }

  void _onDigit(String digit) {
    if (_enteredPin.length >= _pinLength) return;
    HapticFeedback.selectionClick();
    setState(() {
      _enteredPin += digit;
      _hasError    = false;
    });
    if (_enteredPin.length == _pinLength) {
      _checkPin();
    }
  }

  void _onDelete() {
    if (_enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _enteredPin =
        _enteredPin.substring(0, _enteredPin.length - 1));
  }

  Future<void> _checkPin() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_enteredPin == widget.savedPin) {
      HapticFeedback.heavyImpact();
      widget.onUnlocked();
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _hasError   = true;
        _enteredPin = '';
      });
      _shakeCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Logo
            Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end:   Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:      AppColors.primary.withOpacity(0.5),
                        blurRadius: 24,
                        offset:     const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('৳',
                      style: TextStyle(
                        color:      Colors.white,
                        fontSize:   40,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ).animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(),
                const SizedBox(height: 16),
                const Text('HishabKitab',
                  style: TextStyle(
                    color:      Colors.white,
                    fontSize:   24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 6),
                Text(
                  widget.biometricEnabled
                      ? 'Use biometric or enter PIN'
                      : 'Enter your PIN',
                  style: TextStyle(
                    color:    Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ).animate(delay: 300.ms).fadeIn(),
              ],
            ),
            const SizedBox(height: 48),

            // PIN dots
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(
                  _shakeAnim.value > 0
                      ? 12 * (0.5 - _shakeAnim.value).abs() * 4
                      : 0,
                  0,
                ),
                child: child,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (i) {
                  final filled = i < _enteredPin.length;
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
                          ? AppColors.primaryLight
                          : Colors.white.withOpacity(0.25),
                      boxShadow: filled && !_hasError ? [
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ] : null,
                    ),
                  );
                }),
              ),
            ).animate(delay: 400.ms).fadeIn(),

            if (_hasError) ...[
              const SizedBox(height: 12),
              const Text('Incorrect PIN. Try again.',
                style: TextStyle(
                    color: AppColors.expense, fontSize: 13),
              ).animate()
                  .fadeIn(duration: 300.ms)
                  .shakeX(amount: 4, duration: 400.ms),
            ],

            const SizedBox(height: 48),

            // Numpad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  _numRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _numRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _numRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Biometric button
                      if (widget.biometricEnabled)
                        _specialBtn(
                          icon:    Icons.fingerprint_rounded,
                          color:   AppColors.primaryLight,
                          onTap:   _tryBiometric,
                          loading: _isLoading,
                        )
                      else
                        const SizedBox(width: 72),

                      _digitBtn('0'),

                      _specialBtn(
                        icon:  Icons.backspace_outlined,
                        color: Colors.white60,
                        onTap: _onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 500.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1, end: 0),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _numRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map(_digitBtn).toList(),
    );
  }

  Widget _digitBtn(String digit) {
    return GestureDetector(
      onTap: () => _onDigit(digit),
      child: Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        child: Center(
          child: Text(digit,
            style: const TextStyle(
              color:      Colors.white,
              fontSize:   26,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _specialBtn({
    required IconData  icon,
    required Color     color,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72, height: 72,
        child: Center(
          child: loading
              ? SizedBox(
            width: 28, height: 28,
            child: CircularProgressIndicator(
                color: color, strokeWidth: 2),
          )
              : Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}