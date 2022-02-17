import 'package:offline_note/data/provider/database.dart';
import 'package:offline_note/data/provider/json_api.dart';
import 'package:offline_note/data/provider/note_interface.dart';

class NoteRepository {
  static NoteProviderInterface? _provider;
  static setProvider(NoteProviderInterface provider) {
    _provider = provider;
  }

  static getProvider() {
    return _provider;
  }
}
