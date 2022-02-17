import 'dart:async';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:offline_note/data/blocs/bloc_provider.dart';
import 'package:offline_note/data/provider/database.dart';
import 'package:offline_note/data/provider/json_api.dart';

import '../repository/note_repo.dart';

enum NetworkStatus { none, wifi, mobile }

class NetworkBloc implements BlocBase {
  StreamSubscription? _subscription;
  //final _networkController = StreamController<NetworkStatus>.broadcast();
  // Input stream. We add our notes to the stream using this variable.
  // StreamSink<NetworkStatus> get _networkStatus => _networkController.sink;

  NetworkBloc() {
    _handleConnection();
    // Listens for changes to the addNoteController and calls _handleAddNote on change
    //_networkController.stream.listen(_handleConnection);
    //_notesController.stream.listen(_handleConnection);
  }

  // All stream controllers you create should be closed within this function
  @override
  void dispose() {
    //_networkController.close();
    _subscription?.cancel();
    //_addNoteController.close();
  }

  void _handleConnection() async {
    print(await InternetConnectionChecker().hasConnection);
    // returns a bool

    // We can also get an enum value instead of a bool
    print(
        "Current status: ${await InternetConnectionChecker().connectionStatus}");
    _subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        NoteRepository.setProvider(JsonApiProvider.api);
        JsonApiProvider.api.sync(DBProvider.db);
      } else {
        NoteRepository.setProvider(DBProvider.db);
      }
    });
  }
}
