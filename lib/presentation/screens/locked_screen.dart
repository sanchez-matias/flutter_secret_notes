import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secret_notes/presentation/providers/local_auth/local_auth_providers.dart';

class LockedScreen extends StatelessWidget {
  const LockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Password input
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: _PasswordField(),
                ),
              ),
            ),
        
            // Local Auth button
            Padding(
              padding: EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
              child: _BiometricAuthButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends ConsumerWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPasswordRegistered = ref.watch(isPasswordRegisteredProvider);
    final localAuth = ref.watch(localAuthProvider);
    final hasError = !localAuth.didAuthenticate;

    return TextField(
      autocorrect: false,
      obscureText: true,
      autofocus: true,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: 'Password',
        errorText: hasError && localAuth.message.isNotEmpty
          ? localAuth.message
          : null,
        hintStyle: const TextStyle(color: Colors.grey),
        helperText: isPasswordRegistered.whenOrNull(
          data: (data) {
            if (data) {
              return null;
            }

            return 'Type a password to create one and remember it';
          },
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
      onSubmitted: (value) {
        ref.read(localAuthProvider.notifier).authenticateWithPassword(value);
      },
    );
  }
}

class _BiometricAuthButton extends ConsumerWidget {
  const _BiometricAuthButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCheck = ref.watch(canCheckBiometricsProvider);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: canCheck.whenOrNull(
          data: (data) {
            if (!data) {
              return null;
            }

            return () => ref.read(localAuthProvider.notifier).authenticateWithBiometrics();
          },
        ),
        label: const Text('Use biometric auth'),
        icon: const Icon(Icons.fingerprint),
      ),
    );
  }
}
