import 'package:angel_common/angel_common.dart';
import '../models/note.dart';

configureServer(Angel app) async {
  app.use('/api/notes', new TypedService<Note>(new MapService()));
}
