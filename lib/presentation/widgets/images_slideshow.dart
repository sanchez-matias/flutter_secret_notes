import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secret_notes/domain/domain.dart';

class ImagesSlideshow extends StatelessWidget {
  final List<CustomImage> images;

  const ImagesSlideshow({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final paths = images.map((e) => e.path).toList();

    return Container(
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Attached Images', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          _ImagesList(paths: paths),
        ],
      ),
    );
  }
}

class _ImagesList extends StatefulWidget {
  const _ImagesList({
    required this.paths,
  });

  final List<String> paths;

  @override
  State<_ImagesList> createState() => _ImagesListState();
}

class _ImagesListState extends State<_ImagesList> {
  final Set<String> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
        scrollDirection: Axis.horizontal,
        itemCount: widget.paths.length,
        itemBuilder: (context, index) {
          final path = widget.paths[index];

          return GestureDetector(
            onTap: () {
              // Not in selection mode. Pushing Photo Screen.
              if (selectedItems.isEmpty) {
                // TODO: Llevar a una pantalla para ver la imagen mas grande.
                return;
              }

              // We are in selection mode. We need to select or deselect items.
              setState(() {
                if (selectedItems.contains(path)) {
                  selectedItems.remove(path);
                } else {
                  selectedItems.add(path);
                }
              });
            },
            onLongPress: () {
              if (selectedItems.isEmpty) {
                setState(() {
                  selectedItems.add(path);
                });
              }
            },
            child: _ListItem(
              path: path,
              isSelected: selectedItems.contains(path),
            ),
          );
        },
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String path;
  final bool isSelected;

  const _ListItem({
    required this.path,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 100,
        width: 100,
        child: Stack(
          children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  height: 90,
                  width: 90,
                ),
              ),

            if (isSelected)
              Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: colors.primary,
                  size: 33,
                  shadows: const [
                    Shadow(
                      color: Colors.white,
                      offset: Offset(1, 1),
                      blurRadius: 5
                    )
                  ],
                ),
              ),
          ],
        )
      ),
    );
  }
}
