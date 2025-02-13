import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'package:local_auth/error_codes.dart' as auth_error;

class LocalAuthPlugin {
  static final LocalAuthentication auth = LocalAuthentication();

  static aviableBiometrics() async {
    final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      // Some biometrics are enrolled.
    }

    if (availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.face)) {
      // Specific types of biometrics are available.
      // Use checks like this with caut
    }
  }

  static Future<bool> canCheckBiometrics() async {
    return await auth.canCheckBiometrics;
  }

  static Future<(bool, String)> authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please log in',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return (
        didAuthenticate,
        didAuthenticate ? 'Done' : 'Cancelled'
      );
    } on PlatformException catch (e) {
      // print(e);

      if (e.code == auth_error.notEnrolled) return (false, 'Biometrics not enrolled');
      if (e.code == auth_error.lockedOut) return (false, 'There were many failed attempts');
      if (e.code == auth_error.notAvailable) return (false, 'Biometrics not aviable');
      if (e.code == auth_error.passcodeNotSet) return (false, 'Pin is not set');
      if (e.code == auth_error.permanentlyLockedOut) return (false, 'Permanently Locked Out');

      return (false, e.toString());
    }
  }
}
