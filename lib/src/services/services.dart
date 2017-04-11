library notes.services;

import 'package:angel_common/angel_common.dart';
import 'note.dart' as note;
import 'user.dart' as user;

configureServer(Angel app) async {
  await app.configure(note.configureServer);
  await app.configure(user.configureServer);
}
