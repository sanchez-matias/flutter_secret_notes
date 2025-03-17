import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secret_notes/config/plugins/local_auth.dart';
import 'package:flutter_secret_notes/config/plugins/secure_storage_plugin.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_auth_providers.g.dart';

@riverpod
FutureOr<bool> canCheckBiometrics(Ref ref) async {
  return await LocalAuthPlugin.canCheckBiometrics();
}

@riverpod
FutureOr<bool> isPasswordRegistered(Ref ref) async {
  return await SecureStoragePlugin.isPasswordRegistered();
}

enum LocalAuthStatus { authenticated, notAuthenticated, loading }

class LocalAuthState {
  final bool didAuthenticate;
  final LocalAuthStatus status;
  final String message;

  LocalAuthState({
    this.didAuthenticate = false,
    this.status = LocalAuthStatus.notAuthenticated,
    this.message = '',
  });

  LocalAuthState copyWith({
    bool? didAuthenticate,
    LocalAuthStatus? status,
    String? message,
  }) =>
      LocalAuthState(
        didAuthenticate: didAuthenticate ?? this.didAuthenticate,
        status: status ?? this.status,
        message: message ?? this.message,
      );

  @override
  String toString() => '''

    didAuthenticate: $didAuthenticate
    status: $status
    message: $message
''';
}

@riverpod
class LocalAuth extends _$LocalAuth {
  @override
  LocalAuthState build() {
    return LocalAuthState();
  }

  Future<(bool, String)> authenticateWithBiometrics() async {
    // state = state.copyWith(status: LocalAuthStatus.loading);

    final (didAuthenticate, message) = await LocalAuthPlugin.authenticate();

    state = state.copyWith(
      didAuthenticate: didAuthenticate,
      status: didAuthenticate
          ? LocalAuthStatus.authenticated
          : LocalAuthStatus.notAuthenticated,
      message: message,
    );

    return (didAuthenticate, message);
  }

  Future<(bool, String)> authenticateWithPassword(String password) async {
    state = state.copyWith(status: LocalAuthStatus.loading);

    final isPasswordRegistered = await SecureStoragePlugin.isPasswordRegistered();
    
    if (!isPasswordRegistered) {
      await SecureStoragePlugin.setPassword(password);

      state = state.copyWith(
        didAuthenticate: true,
        status: LocalAuthStatus.authenticated,
        message: 'Password created'
      );

      return (true, 'Password Created');
    }

    final savedPassword = await SecureStoragePlugin.getPassword();

    if (password == savedPassword) {
      state = state.copyWith(
        didAuthenticate: true,
        status: LocalAuthStatus.authenticated,
        message: 'Success'
      );

      return (true, 'Success');
    } else {
      state = state.copyWith(message: 'Incorrect Password');
      return (false, 'Incorrect Password');
    }
  }

  Future<void> setPassword(String newPassword) async {
    await SecureStoragePlugin.setPassword(newPassword);

    state = state.copyWith(
        didAuthenticate: false,
        status: LocalAuthStatus.notAuthenticated,
        message: 'Logged out for password changing'
      );
  }
}
