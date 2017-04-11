library notes.routes.controllers.auth;

import 'package:angel_auth_google/angel_auth_google.dart';
import 'package:angel_common/angel_common.dart';
import 'package:googleapis/plus/v1.dart';
import '../../services/user.dart';

const List<String> GOOGLE_AUTH_SCOPES = const [
  PlusApi.PlusMeScope,
  PlusApi.UserinfoEmailScope,
  PlusApi.UserinfoProfileScope
];

@Expose('/auth')
class AuthController extends Controller {
  AngelAuth auth;

  /// Clients will see the result of `deserializer`, so let's pretend to be a client.
  ///
  /// Our User service is already wired to remove sensitive data from serialized JSON.
  deserializer(String id) async =>
      app.service('api/users').read(id, {'provider': Providers.REST});

  serializer(User user) async => user.id;

  GoogleAuthCallback googleVerifier(Service userService) {
    return (_, Person profile) async {
      List<User> users = await userService.index({
        'query': {'googleId': profile.id}
      });

      if (users.isNotEmpty)
        return users.first;
      else {
        return await userService.create({
          'googleId': profile.id,
          'email': profile.emails.first.value,
          'name': profile.displayName
        });
      }
    };
  }

  @override
  call(Angel app) async {
    // Wire up local authentication, connected to our User service
    auth = new AngelAuth(jwtKey: app.jwt_secret, allowCookie: false)
      ..serializer = serializer
      ..deserializer = deserializer
      ..strategies.add(new GoogleStrategy(
          callback: googleVerifier(app.service('api/users')),
          config: app.google,
          scopes: GOOGLE_AUTH_SCOPES));

    await super.call(app);
    await app.configure(auth);
  }

  @Expose('/google')
  googleAuth() => auth.authenticate('google');

  @Expose('/google/callback')
  googleAuthCallback() => auth.authenticate('google', new AngelAuthOptions(
          callback: (req, ResponseContext res, token) async {
        res.redirect('/?token=$token');
      }));
}
