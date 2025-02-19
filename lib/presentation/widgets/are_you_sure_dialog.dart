import 'package:flutter/material.dart';

class AreYouSureDialog extends StatelessWidget {
  final void Function() callback; 

  const AreYouSureDialog({super.key, required this.callback});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are You Sure?'),
      content: const Text('This action can not be undone.'),
      actions: [
        FilledButton(
          onPressed: () {
            callback();
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
