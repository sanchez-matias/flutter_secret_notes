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
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [

        //* NOTE CONTAINER
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                          ? colors.primary
                          : Colors.black,
                      ),
                    ),
                  ),


                Text(note.content, maxLines: 10, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),

        //* SELECTED CHECK
        Positioned(
          top: size.height * 0.015,
          right: size.width * 0.05,
          child: isSelected
            ? Icon(Icons.check_circle, color: colors.primary)
            : const SizedBox(),
        ),
      ],
    );
  }
}
