import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secret_notes/presentation/providers/local_auth/local_auth_providers.dart';

class LockedScreen extends ConsumerWidget {
  const LockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () {
            ref.read(localAuthProvider.notifier).authenticateUser();
          },
          child: const Text('Authenticate'),
        ),
      ),
    );
  }
}
