import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_secret_notes/infrastructure/datasources/local_db_datasource_impl.dart';
import 'package:flutter_secret_notes/infrastructure/repositories/local_db_repository_impl.dart';

class NoteSearchDelegate extends SearchDelegate {
  final database = LocalDbRepositoryImpl(LocalDbDatasourceImpl());

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, 'result');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return const SizedBox();

    return FutureBuilder(
      future: database.searchNote(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('Loading...'));
        }

        if (snapshot.hasError) {
          return Center(child: Text('ERROR: ${snapshot.error}'));
        }

        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final note = snapshot.data![index];

            return ListTile(
              title: Text(note.title),
              subtitle: Text(note.content),
              onTap: () {
                context.push('/home/note/${note.id}');
              },
            );
          },
        );

      },
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  const _SuggestionItem();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('Hola'),
      subtitle: Text(
          'Esse culpa fugiat cillum ea esse. Qui incididunt fugiat cillum nulla aliqua ex officia enim pariatur exercitation sint. Enim id ullamco aliqua exercitation exercitation. Ullamco esse enim tempor irure dolore nostrud labore anim nulla nisi culpa. Quis proident aute laborum nisi quis.'),
    );
  }
}
