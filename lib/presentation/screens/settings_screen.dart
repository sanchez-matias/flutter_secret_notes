import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secret_notes/presentation/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    final tileColor = Theme.of(context).colorScheme.primary.withOpacity(0.2);
    final tileShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            ExpansionTile(
              title: const Text('Permissions'),
              shape: tileShape,
              collapsedShape: tileShape,
              backgroundColor: tileColor,
              collapsedBackgroundColor: tileColor,
              expansionAnimationStyle: AnimationStyle(curve: Curves.easeInCubic),
              children: [
                CheckboxListTile.adaptive(
                  value: permissions.isCameraGranted,
                  onChanged: (value) {
                    ref.read(permissionsProvider.notifier)
                      .requestCameraAccess();
                  },
                  title: const Text('Camera'),
                ),
                CheckboxListTile.adaptive(
                  value: permissions.isGaleryGranted,
                  onChanged: (value) {
                    ref.read(permissionsProvider.notifier)
                      .requestGaleryAccess();
                  },
                  title: const Text('Galery'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ListTile(
              title: const Text('Change password'),
              shape: tileShape,
              trailing: const Icon(Icons.fingerprint),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const _ChangePasswordDialog(),
                );
              },
            ),
          ],
        ));
  }
}


class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  bool hideText = true;
  final controller = TextEditingController();

  void toggleObscureText() {
    setState(() {
      hideText = !hideText;
    });
  }

  void showCustomSnackBar(String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> onSubmitted() async {
    final (didAuthenticate, message) = await ref.read(localAuthProvider.notifier)
      .authenticateWithBiometrics();
    
    if (didAuthenticate) {
      showCustomSnackBar('Success');

      await ref.read(localAuthProvider.notifier).setPassword(controller.text);
    } else {
      showCustomSnackBar('Error: $message');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: TextField(
        obscureText: hideText,
        decoration: InputDecoration(
            suffixIcon: IconButton(
            onPressed: () {
              toggleObscureText();
            },
            icon: hideText
              ? const Icon(Icons.remove_red_eye_outlined)
              : const Icon(Icons.password),
          ),
        ),
        onSubmitted: (value) => onSubmitted(),
      ),
      actions: [
        FilledButton(
          onPressed: () => onSubmitted(),
          child: const Text('Submit'),
        ),
      ],
    ); 
  }
}
