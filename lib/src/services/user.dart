import 'package:angel_common/angel_common.dart';
import 'package:crypto/crypto.dart' show sha256;
import '../models/user.dart';
export '../models/user.dart';

configureServer(Angel app) async {
  app.use('/api/users', new TypedService<User>(new MapService()));
}

/// SHA-256 hash any string, particularly a password.
String hashPassword(String password, String salt, String pepper) =>
    sha256.convert(('$salt:$password:$pepper').codeUnits).toString();
