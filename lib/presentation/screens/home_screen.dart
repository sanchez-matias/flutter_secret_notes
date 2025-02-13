import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secret_notes/domain/entities/note.dart';
import 'package:flutter_secret_notes/presentation/delegates/note_search_delegate.dart';
import 'package:flutter_secret_notes/presentation/providers/providers.dart';
import 'package:flutter_secret_notes/presentation/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController();

    controller.addListener(
      () {
        if (controller.page != null && controller.page! > 0.5) {
          ref.read(selectedNotesProvider.notifier).removeAll();
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onDestinationSelected(int index) {
    controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedNotes = ref.watch(selectedNotesProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Secret Notes', style: TextStyle(color: selectedNotes.isEmpty ? null : Colors.white)),
        backgroundColor: selectedNotes.isEmpty
          ? null
          : colors.primary,
        actions: [
          selectedNotes.isEmpty
              ? IconButton(
                  onPressed: () {
                    context.push('/home/settings');
                  },
                  icon: const Icon(Icons.settings),
                )

              : IconButton(
                  onPressed: () {
                    ref.read(notesProvider.notifier).deleteNote(selectedNotes.toList());
                    ref.read(selectedNotesProvider.notifier).removeAll();
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                ),
        ],
      ),
      body: PageView(
        controller: controller,
        onPageChanged: _onPageChanged,
        children: const [
          _NotesView(),

          _SearchView()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/home/note/-1');
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.note), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}

class _NotesView extends ConsumerWidget {
  const _NotesView();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final selectedNotes = ref.watch(selectedNotesProvider);

    final isSelectionMode = selectedNotes.isNotEmpty;

    if (notes.isEmpty) {
      return const Center(child: Text('No content added'));
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = selectedNotes.contains(note.id);

        return GestureDetector(
          onLongPress: () {
            if (isSelectionMode) return;

            ref.read(selectedNotesProvider.notifier).addId(note.id);
          },
          onTap: () {
            if (isSelectionMode) {
              if (isSelected) {
                ref.read(selectedNotesProvider.notifier).remove(note.id);
              } else {
                ref.read(selectedNotesProvider.notifier).addId(note.id);
              }
              return;
            }

            context.push('/home/note/${note.id}');
            ref.read(selectedNotesProvider.notifier).removeAll();
          },
          child: ListItem(
            note: note,
            isSelected: isSelected,
          ),
        );
      },
    );
  }
}

class _SearchView extends ConsumerWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastVisited = ref.watch(lastVisitedNotesProvider);
    final size = MediaQuery.sizeOf(context);

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(),
              );
            },
            child: Container(
              padding: const EdgeInsets.only(left: 20),
              height: 60,
              width: size.width * 0.9,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all()),
              child: const Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 15),
                  Text('Type what you\'re looking for!')
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),
          const Text('Recently Visited Notes'),
          ...List.generate(lastVisited.length,
              (index) => _LastVisitedListItem(lastVisited[index])),
        ],
      ),
    );
  }
}

class _LastVisitedListItem extends ConsumerWidget {
  final Note note;

  const _LastVisitedListItem(this.note);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ListTile(
        dense: true,
        title: Text(note.title),
        subtitle: Text(note.content, maxLines: 2),
        onTap: () {
          context.push('/home/note/${note.id}');
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
