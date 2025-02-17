import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_secret_notes/domain/domain.dart';
import 'package:flutter_secret_notes/presentation/providers/providers.dart';
import 'package:flutter_secret_notes/presentation/widgets/images_slideshow.dart';

class NoteScreen extends ConsumerWidget {
  final int noteId;

  const NoteScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedNote = ref.watch(getNoteProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(noteId < 0 ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(notesProvider.notifier).pickFromCamera(noteId);
            },
            icon: const Icon(Icons.add_a_photo_outlined),
          ),

          IconButton(
            onPressed: () async {
              await ref.read(notesProvider.notifier).pickFromGallery(noteId);
            },
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
        ],
      ),
      body: selectedNote.when(
        error: (error, stackTrace) => Text('ERROR GETTING NOTES: $error'),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (data) {
          if (data == null) {
            return const _NoteForm(title: '', content: '', images: []);
          }
    
          return _NoteForm(
            id: data.id,
            title: data.title,
            content: data.content,
            images: data.mediaPaths,
          );
        },
      ),
    );
  }
}

class _NoteForm extends ConsumerStatefulWidget {
  final int id;
  final String title;
  final String content;
  final List<CustomImage> images;

  const _NoteForm({
    this.id = -1,
    required this.title,
    required this.content,
    required this.images,
  });

  @override
  ConsumerState<_NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends ConsumerState<_NoteForm> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    
    titleController = TextEditingController(text: widget.title);
    contentController = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        final editedNote = Note(
          id: widget.id,
          title: titleController.text,
          content: contentController.text,
        );

        if (editedNote.isEmpty) return;

        if (widget.id > 0) {
          ref
            .read(notesProvider.notifier)
            .editNote(editedNote);

          // print('Se edito una nota');
        } else {
          final id = await ref.read(notesProvider.notifier).addNewNote(editedNote);

          // Update the last visited notes when created
          ref.read(lastVisitedNotesProvider.notifier).insertNote(id);
        }


      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
      
              // Title
              TextFormField(
                controller: titleController,
                enableSuggestions: false,
                maxLines: 2,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Title',
                ),
              ),

              const SizedBox(height: 15),

              if (widget.images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: ImagesSlideshow(images: widget.images),
                ),
      
              // Body
              SizedBox(
                height: size.height * 0.5,
                child: TextFormField(
                  textAlignVertical: const TextAlignVertical(y: -1),
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
