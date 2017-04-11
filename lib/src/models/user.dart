library notes.models.user;

import 'package:angel_framework/common.dart';

class User extends Model {
  @override
  String id;
  String googleId, email, name;
  @override
  DateTime createdAt, updatedAt;

  User(
      {this.id,
      this.googleId,
      this.email,
      this.name,
      this.createdAt,
      this.updatedAt});
}
