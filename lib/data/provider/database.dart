import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:offline_note/data/provider/note_interface.dart';
import 'package:offline_note/models/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider implements NoteProviderInterface {
  // Create a singleton
  DBProvider._();

  static final DBProvider db = DBProvider._();
  Database? _database = null;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDB();
    return _database!;
  }

  initDB() async {
    // Get the location of our apps directory. This is where files for our app, and only our app, are stored.
    // Files in this directory are deleted when the app is deleted.
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'app.db');

    return await openDatabase(path, version: 1, onOpen: (db) async {},
        onCreate: (Database db, int version) async {
      // Create the note table
      await db.execute('''
				CREATE TABLE note(
					id INTEGER PRIMARY KEY,
					contents TEXT DEFAULT '',
          isSync INTEGER DEFAULT 0
				)
			''');
    });
  }

  /*
	 * Note Table
	 */
  @override
  newNote(Note note) async {
    final db = await database;
    var res = await db.insert('note', note.toJson());
    if (res == 0) return throw Exception("Failed to add Note");
    note.id = res;
    return note;
  }

  @override
  getNotes() async {
    final db = await database;
    var res = await db.query('note');
    List<Note> notes =
        res.isNotEmpty ? res.map((note) => Note.fromJson(note)).toList() : [];

    print('Getting Notes');
    print(jsonEncode(notes));
    return notes;
  }

  @override
  getNote(int id) async {
    final db = await database;
    var res = await db.query('note', where: 'id = ?', whereArgs: [id]);
    if (res.isEmpty) throw Exception("Failed to add Note");
    return Note.fromJson(res.first);
  }

  @override
  Future<Note> updateNote(Note note) async {
    final db = await database;
    var res = await db
        .update('note', note.toJson(), where: 'id = ?', whereArgs: [note.id]);
    if (res == 0) return throw Exception("Failed to add Note");
    return note;
  }

  @override
  Future<bool> deleteNote(int id) async {
    final db = await database;

    var res = await db.delete('note', where: 'id = ?', whereArgs: [id]);
    return res != 0 ? true : false;
  }

  getNotSyncNotes() async {
    final db = await database;
    var res = await db.query('note', where: '(isSync = 0 OR isSync is NULL)');
    List<Note> notes =
        res.isNotEmpty ? res.map((note) => Note.fromJson(note)).toList() : [];

    return notes;
  }
}
