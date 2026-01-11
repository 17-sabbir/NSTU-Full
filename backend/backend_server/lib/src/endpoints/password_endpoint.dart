import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

class PasswordEndpoint extends Endpoint {
  Future<String> changePasswordByUserIdEmail(
      Session session, {
        required int userId,
        required String email,
        required String currentPassword,
        required String newPassword,
      }) async {
    return _changePasswordByUserIdEmail(
      session,
      userId: userId,
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

// Raw helper function (private)
Future<String> _changePasswordByUserIdEmail(
    Session session, {
      required int userId,
      required String email,
      required String currentPassword,
      required String newPassword,
    }) async {
  final currentHash = sha256.convert(utf8.encode(currentPassword)).toString();

  final rows = await session.db.unsafeQuery(
    r'''
    SELECT user_id FROM users 
    WHERE user_id = @userId AND email = @email 
      AND password_hash = @currentHash AND is_active = true
    ''',
    parameters: QueryParameters.named({
      'userId': userId,
      'email': email,
      'currentHash': currentHash,
    }),
  );

  if (rows.isEmpty) return 'INVALID_CREDENTIALS';

  final newHash = sha256.convert(utf8.encode(newPassword)).toString();

  final updated = await session.db.unsafeExecute(
    r'''
    UPDATE users SET password_hash = @newHash 
    WHERE user_id = @userId AND email = @email AND is_active = true
    ''',
    parameters: QueryParameters.named({
      'newHash': newHash,
      'userId': userId,
      'email': email,
    }),
  );

  return updated == 1 ? 'OK' : 'FAILED';
}
