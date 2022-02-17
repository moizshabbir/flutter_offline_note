import 'package:offline_note/models/note_model.dart';

abstract class NoteProviderInterface {
  Future<Note> newNote(Note note);
  Future<List<Note>> getNotes();
  Future<Note> getNote(int id);
  Future<Note> updateNote(Note note);
  Future<bool> deleteNote(int id);
}
