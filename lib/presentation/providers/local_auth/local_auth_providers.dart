import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secret_notes/config/plugins/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_auth_providers.g.dart';

@riverpod
FutureOr<bool> canCheckBiometrics(Ref ref) async {
  return await LocalAuthPlugin.canCheckBiometrics();
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

  Future<(bool, String)> authenticateUser() async {
    state = state.copyWith(status: LocalAuthStatus.loading);

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
}
