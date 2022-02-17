import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:offline_note/data/provider/database.dart';
import 'package:offline_note/data/provider/note_interface.dart';

import '../../models/note_model.dart';

class JsonApiProvider implements NoteProviderInterface {
  // Create a singleton
  JsonApiProvider._();

  static final JsonApiProvider api = JsonApiProvider._();

  final _baseUrl = 'https://jsonplaceholder.typicode.com';
//   final client = http;

  Map<int?, Note> notes = Map<int?, Note>();

  @override
  Future<Note> newNote(Note note) async {
    dynamic body = note.toApiJson();
    final result = await http.post(Uri.parse('$_baseUrl/posts'),
        headers: {"content-type": "application/x-www-form-urlencoded"},
        body: body);
    if (result.statusCode == 201) {
      return Note.fromApiJson(jsonDecode(result.body));
    }
    throw Exception("Failed to add Note");
  }

  @override
  Future<List<Note>> getNotes() async {
    final results = await http.get(Uri.parse('$_baseUrl/posts'));
    if (results.statusCode == 200) {
      return compute(parseNotes, results.body);
    }
    throw Exception("Failed to get Notes");
  }

  @override
  Future<Note> getNote(int id) async {
    final result = await http.get(Uri.parse('$_baseUrl/posts/$id'));
    if (result.statusCode == 200) {
      return Note.fromApiJson(jsonDecode(result.body));
    }
    throw Exception("Failed to get Note");
  }

  @override
  Future<Note> updateNote(Note note) async {
    int id = note.id!;
    final result = await http.put(Uri.parse('$_baseUrl/posts/$id'),
        body: jsonEncode(note.toApiJson()));
    if (result.statusCode == 200) {
      return note; //(jsonDecode(result.body));
    }
    throw Exception("Failed to update Note");
  }

  @override
  Future<bool> deleteNote(int id) async {
    final result = await http.delete(Uri.parse('$_baseUrl/posts/$id'));
    if (result.statusCode == 200) {
      return true;
    }
    throw Exception("Failed to get Notes");
  }

  sync(DBProvider provider) async {
    List<Note> offlineNotes = await provider.getNotSyncNotes();
    List<Note> onlineNotes = await api.getNotes();

    for (var element in onlineNotes) {
      mapNotes(element);
    } // .map<Note>((note) => mapNotes(note));
    print("Syncing notes");
    print(jsonEncode(offlineNotes));
    print(onlineNotes.length);
    //print(jsonEncode(notes));
    for (var note in offlineNotes) {
      if (notes[note.id] == null) {
        await api.newNote(note);
      } else {
        await api.updateNote(note);
      }
      note.isSync = 1;
      await provider.updateNote(note);
    }
  }

  mapNotes(note) {
    notes[note.id] = note;
  }

  List<Note> parseNotes(dynamic responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Note>((json) => Note.fromApiJson(json)).toList();
  }
}
