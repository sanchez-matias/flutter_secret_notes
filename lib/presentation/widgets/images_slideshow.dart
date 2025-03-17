import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secret_notes/domain/domain.dart';
import 'package:flutter_secret_notes/presentation/providers/notes/notes_provider.dart';
import 'package:flutter_secret_notes/presentation/widgets/widgets.dart';

final selectedImagesProvider = StateProvider.autoDispose<Set<int>>((ref) => {});

class ImagesSlideshow extends ConsumerWidget {
  final List<CustomImage> images;

  const ImagesSlideshow({super.key, required this.images});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedImagesProvider);
    final isSelectionMode = selectedIds.isNotEmpty;

    final selectedImages = images.where((element) => selectedIds.contains(element.id)).toList();

    return Container(
      // height: isSelectionMode ? 150 : 200,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          // const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Text('Attached Images', style: TextStyle(fontWeight: FontWeight.bold)),
          // ),

          _ImagesList(images: images),

          if (isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: 200,
                height: 50,
                  child: TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AreYouSureDialog(
                          callback: () {
                            ref.read(notesProvider.notifier).deleteImages(selectedImages);
                            ref.read(selectedImagesProvider.notifier).state = {};
                          },
                        ),
                      );
                    },
                    label: const Text('Delete'),
                    icon: const Icon(Icons.delete_rounded),
                  )
              ),
            ),
        ],
      ),
    );
  }
}

class _ImagesList extends ConsumerWidget {
  const _ImagesList({
    required this.images,
  });

  final List<CustomImage> images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImages = ref.watch(selectedImagesProvider);

    return SizedBox(
      height: 100,
      child: ListView.separated(
        physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (context, index) {
          final image = images[index];

          return GestureDetector(
            onTap: () {
              // Not in selection mode. Pushing Photo Screen.
              if (selectedImages.isEmpty) {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => _ImageDialog(image.path),
                );

                return;
              }

              // We are in selection mode. We need to select or deselect items.
              if (selectedImages.contains(image.id)) {
                  ref.read(selectedImagesProvider.notifier)
                    .update((state) => {...state}..remove(image.id));
                } else {
                  ref.read(selectedImagesProvider.notifier)
                    .update((state) => {...state}..add(image.id));
                }
            },
            onLongPress: () {
              // We want to add the first item to selected images and start selection mode.
              if (selectedImages.isEmpty) {
                ref.read(selectedImagesProvider.notifier)
                  .update((state) => {image.id});
              }
            },
            child: _ListItem(
              path: image.path,
              isSelected: selectedImages.contains(image.id),
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

    return Stack(
      children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              height: 100,
              width: 100,
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
    );
  }
}

class _ImageDialog extends ConsumerWidget {
  final String path;

  const _ImageDialog(this.path);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [

        // Image
        Center(
          child: InteractiveViewer(
            child: Image.file(
              File(path),
              fit: BoxFit.contain,
              isAntiAlias: true,
            ),
          ),
        ),

        // Control bar
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(5),
              width: size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  IconButton(
                    onPressed: () {
                      // ref.read(notesProvider.notifier).deleteImages([path]);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}