import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secret_notes/presentation/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          children: [
            CheckboxListTile.adaptive(
              value: permissions.isCameraGranted,
              onChanged: (value) {
                ref.read(permissionsProvider.notifier).requestCameraAccess();
              },
              title: const Text('Camera'),
            ),
            
            CheckboxListTile.adaptive(
              value: permissions.isGaleryGranted,
              onChanged: (value) {
                ref.read(permissionsProvider.notifier).requestGaleryAccess();
              },
              title: const Text('Galery'),
            ),
          ],
        ));
  }
}
