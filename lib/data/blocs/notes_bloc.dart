import 'dart:async';

import 'package:offline_note/data/blocs/bloc_provider.dart';
import 'package:offline_note/models/note_model.dart';

import '../repository/note_repo.dart';

class NotesBloc implements BlocBase {
  int id = 0;
  // Create a broadcast controller that allows this stream to be listened
  // to multiple times. This is the primary, if not only, type of stream you'll be using.
  final _notesController = StreamController<List<Note>>.broadcast();

  // Input stream. We add our notes to the stream using this variable.
  StreamSink<List<Note>> get _inNotes => _notesController.sink;

  // Output stream. This one will be used within our pages to display the notes.
  Stream<List<Note>> get notes => _notesController.stream;

  // Input stream for adding new notes. We'll call this from our pages.
  final _addNoteController = StreamController<Note>.broadcast();
  StreamSink<Note> get inAddNote => _addNoteController.sink;

  NotesBloc() {
    // Retrieve all the notes on initialization
    getNotes();

    // Listens for changes to the addNoteController and calls _handleAddNote on change
    _addNoteController.stream.listen(_handleAddNote);
  }

  // All stream controllers you create should be closed within this function
  @override
  void dispose() {
    _notesController.close();
    _addNoteController.close();
  }

  void getNotes() async {
    // Retrieve all the notes from the database
    final _provider = NoteRepository.getProvider();
    List<Note> notes = [];
    if (_provider != null) {
      notes = await _provider.getNotes();

      // Add all of the notes to the stream so we can grab them later from our pages
      id = notes.length;
    }
    _inNotes.add(notes);
  }

  void _handleAddNote(Note note) async {
    //note.id = id + 1;
    // Create the note in the database
    await NoteRepository.getProvider().newNote(note);

    // Retrieve all the notes again after one is added.
    // This allows our pages to update properly and display the
    // newly added note.
    getNotes();
  }
}
