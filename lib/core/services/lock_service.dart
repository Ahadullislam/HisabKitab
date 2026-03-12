import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

enum LockResult { success, failure, notAvailable, cancelled }

class LockService {
  LockService._();
  static final _instance = LockService._();
  factory LockService() => _instance;

  final _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck  = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<LockResult> authenticate({
    String reason = 'Authenticate to access HishabKitab',
  }) async {
    try {
      final success = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth:  true,
          biometricOnly: false,
        ),
      );
      return success ? LockResult.success : LockResult.failure;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled) {
        return LockResult.notAvailable;
      }
      if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        return LockResult.failure;
      }
      return LockResult.cancelled;
    }
  }
}