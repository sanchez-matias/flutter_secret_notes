import 'dart:developer';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_secret_notes/domain/domain.dart';
import 'package:flutter_secret_notes/config/plugins/path_builder.dart';
import 'package:flutter_secret_notes/infrastructure/models/models.dart';


class LocalDbDatasourceImpl extends LocalDbDatasource {
  late Future<Database> _db;

  final String notesTableName = 'Notes';
  final String imagesTableName = 'Images';
  final String imagesMapTableName = 'ImagesMap';
  final String lastVisitedTableName = 'LastVisited';

  LocalDbDatasourceImpl() {
    _db = openDbInstance();
  }

  Future<Database> openDbInstance() async {
    // final documentsDirectory = await getApplicationDocumentsDirectory();

    // final String customFolder = '${documentsDirectory.path}${Platform.pathSeparator}secret_storage';
    // final String dbPath = '$customFolder${Platform.pathSeparator}storage.db';

    final dbPath = await PathBuilder.buildPath(folderName: 'storage', fileName: 'notes_tables.db');

    final database = openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        //* Create Tables
        db.execute('''
        CREATE TABLE $notesTableName (
	        NoteID	INTEGER PRIMARY KEY AUTOINCREMENT,
	        Content	TEXT,
	        Title	TEXT)
        ''');

        db.execute('''
        CREATE TABLE $imagesTableName (
          ImageID INTEGER PRIMARY KEY AUTOINCREMENT,
          ImagePath TEXT)
        ''');

        db.execute('''
        CREATE TABLE $imagesMapTableName (
          EntryID INTEGER PRIMARY KEY AUTOINCREMENT,
          ImageID INTEGER,
          NoteID INTEGER)
        ''');

        db.execute('''
        CREATE TABLE $lastVisitedTableName (
          EntryID INTEGER PRIMARY KEY AUTOINCREMENT,
          NoteID INTEGER)
        ''');

        // Insert an Example Note
        db.rawInsert('''
        INSERT INTO $notesTableName (Content, Title)
        VALUES ('This is a simple note. It has not an image attached to it but you can do it if you use one of the top right options', 'Example Note')
        ''').then((value) => log('INSERTED EXAMPLE NOTE WITH ID: $value'));

        // print('DATABASE CORRECTLY CREATED! :D');
      },
    );

    return database;
  }

  //* NOTES

  @override
  Future<int> createNote(Note note) async {
    final db = await _db;

    final id = await db.transaction<int>(
      (txn) async => txn.rawInsert('''
        INSERT INTO $notesTableName(Content, Title)
        VALUES('${note.content}', '${note.title}');
        '''),
        );

    log('NOTE CREATED WITH ID: $id');

    return id;
  }

  @override
  Future<void> deleteNotesById(List<int> ids) async {
    if (ids.isEmpty) return;

    final db = await _db;

    final placeholders = List.filled(ids.length, '?').join(',');

    await db.rawDelete('''
    DELETE FROM $imagesMapTableName WHERE NoteID IN ($placeholders)
    ''',
    ids,
    ).then((value) => log('REMOVED $value ROWS FROM $imagesMapTableName'));

    await db.rawDelete('''
    DELETE FROM $notesTableName WHERE NoteID IN ($placeholders)
    ''',
    ids,
    ).then((value) => log('REMOVED $value ROWS FROM $notesTableName'));
  }

  @override
  Future<Note> getNoteById(int id) async {
    final db = await _db;

    // Get the note from DB
    final query = await db.rawQuery('''
    SELECT * FROM $notesTableName
    WHERE NoteID = $id;
    ''');

    // Add to the json all the images paths linked to this note
    var rawNote = Map<String, dynamic>.from(query.first);
    final imagesIds = await getImagesById(id);
    rawNote['paths'] = imagesIds;
    log('GOT NOTE MAP: $rawNote');

    // Return the note with all the data
    return NoteModel.fromJson(rawNote);
  }

  @override
  Future<List<Note>> getNotes({int page = 1}) async {
    final db = await _db;

    final query = await db.rawQuery('''
    SELECT * FROM $notesTableName
    ORDER BY NoteID DESC
    LIMIT ${page * 10}
    ''');

    // print('YOUR QUERY: $query');
    return query.map((e) => NoteModel.fromJson(e)).toList();
  }

  @override
  Future<void> updateNoteById(Note newNoteContent) async {
    final db = await _db;

    await db.rawUpdate('''
    UPDATE $notesTableName
    SET Content = '${newNoteContent.content}', Title = '${newNoteContent.title}'
    WHERE NoteID = ${newNoteContent.id};
    ''').then((value) => log('UPDATED $value ROWS'));
  }

  @override
  Future<List<Note>> searchNote(String query) async {
    final db = await _db;
 
    final databaseQuery = await db.rawQuery('''
    SELECT * FROM $notesTableName
    WHERE Title LIKE '%$query%' OR Content LIKE '%$query%'
    ''');

    return databaseQuery.map((e) => NoteModel.fromJson(e)).toList();
  }

  //* LAST VISITED NOTES

  @override
  Future<List<Note>> getLastVisitedNotes() async {
    final db = await _db;

    final query = await db.rawQuery('''
    SELECT * FROM $notesTableName
    WHERE NoteID IN (
      SELECT NoteID FROM $lastVisitedTableName
      ORDER BY EntryID DESC
    )
    ''');

    log('GOT LAST VISITED NOTES: $query');

    return query.map((e) => NoteModel.fromJson(e)).toList();
  }

  @override
  Future<void> deleteLastVisitedNote(List<int> ids) async {
    if (ids.isEmpty) return;

    final db = await _db;

    final placeholders = List.filled(ids.length, '?').join(',');

    await db.rawDelete('''
    DELETE FROM $lastVisitedTableName WHERE NoteID IN ($placeholders)
    ''',
    ids,
    ).then((value) => log('REMOVED $value ROWS FROM $lastVisitedTableName'));
  }
  
  @override
  Future<void> insertLastVisitedNotes(int id) async {
    final db = await _db;

    await db.rawInsert('''
    INSERT INTO $lastVisitedTableName(NoteID)
    VALUES($id)
    ''').then((value) => log('INSERTED NEW ROW ON $lastVisitedTableName WITH ID $value'));
  }

  //* IMAGES

  @override
  Future<int> addImage(String path) async {
    final db = await _db;

    final id = await db.transaction<int>(
      (txn) async => await txn.rawInsert('''
        INSERT INTO $imagesTableName(ImagePath)
        VALUES('$path');
        '''),
    );

    log('ADDED IMAGE PATH WITH ID: $id');

    return id;
  }

  @override
  Future<void> removeImage(int imageId) async {
    final db = await _db;

    await db.rawDelete('''
    DELETE FROM $imagesMapTableName WHERE ImageID = $imageId;
    ''').then((value) => log('REMOVED $value ROWS FROM $imagesMapTableName'));

    await db.rawDelete('''
    DELETE FROM $imagesTableName
    WHERE ImageID = $imageId;
    ''').then((value) => log('REMOVED $value ROWS FROM $imagesTableName'));
  }

  @override
  Future<List<CustomImage>> getImagesById(int noteId) async {
    final db = await _db;

    final imagesIds = await db.rawQuery('''
    SELECT * FROM $imagesTableName
    WHERE ImageID IN (
      SELECT ImageID FROM $imagesMapTableName
      WHERE NoteID = $noteId)
    ''');

    log('GOT IMAGES OBJECTS: $imagesIds');

    return imagesIds.map((e) => CustomImageModel.fromJson(e)).toList();
  }

  @override
  Future<void> linkImage({required int noteId, required int imageId}) async {
    final db = await _db;

    await db.transaction((txn) =>
      txn.rawInsert('''
      INSERT INTO $imagesMapTableName(ImageID, NoteID)
      VALUES($imageId, $noteId);
      ''')
    );
  }
  
  
  
}
