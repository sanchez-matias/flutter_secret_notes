import 'package:flutter/material.dart';
import 'package:flutter_secret_notes/domain/entities/note.dart';

class ListItem extends StatelessWidget {
  final Note note;
  final bool isSelected;

  const ListItem({
    super.key,
    required this.note,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [

        //* NOTE CONTAINER
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: colors.primary,
                width: isSelected
                  ? 3.0
                  : 1.0
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      note.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),


                Text(note.content),
              ],
            ),
          ),
        ),

        //* SELECTED CHECK
        Positioned(
          top: 15,
          right: 15,
          child: isSelected
            ? Icon(Icons.check_circle, color: colors.primary)
            : const SizedBox(),
        ),
      ],
    );
  }
}
