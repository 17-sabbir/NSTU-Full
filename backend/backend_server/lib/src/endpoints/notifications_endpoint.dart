import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class NotificationEndpoint extends Endpoint {


  // 1. Create Notification (Updated to accept userId if needed,
  // or you can keep passing it from where you trigger this)
  Future<bool> createNotification(
      Session session, {
        required int userId, // Passed explicitly
        required String title,
        required String message,
      }) async {
    try {
      await session.db.unsafeExecute(
        '''
        INSERT INTO notifications (user_id, title, message, is_read, created_at)
        VALUES (@uid, @t, @m, FALSE, NOW())
        ''',
        parameters: QueryParameters.named({
          'uid': userId,
          't': title.trim(),
          'm': message.trim(),
        }),
      );
      return true;
    } catch (e, st) {
      session.log(
        'createNotification failed: $e',
        level: LogLevel.error,
        stackTrace: st,
      );
      return false;
    }
  }

  // 2. Get Notifications (Accepts userId)
  Future<List<NotificationInfo>> getMyNotifications(
      Session session, {
        required int limit,
        required int userId, // <--- Added parameter
      }) async {
    final rows = await session.db.unsafeQuery(
      '''
      SELECT notification_id, user_id, title, message, is_read, created_at
      FROM notifications
      WHERE user_id = @uid
      ORDER BY created_at DESC
      LIMIT @lim
      ''',
      parameters: QueryParameters.named({'uid': userId, 'lim': limit}),
    );

    return rows.map((r) {
      final m = r.toColumnMap();
      return NotificationInfo(
        notificationId: m['notification_id'] as int,
        userId: m['user_id'] as int,
        title: (m['title'] as String?) ?? '',
        message: (m['message'] as String?) ?? '',
        isRead: (m['is_read'] as bool?) ?? false,
        createdAt: m['created_at'] as DateTime,
      );
    }).toList();
  }

  // 3. Get Counts (Accepts userId)
  Future<Map<String, int>> getMyNotificationCounts(
      Session session, {
        required int userId, // <--- Added parameter
      }) async {
    final rows = await session.db.unsafeQuery(
      '''
      SELECT
        SUM(CASE WHEN is_read = FALSE THEN 1 ELSE 0 END)::int AS unread,
        SUM(CASE WHEN is_read = TRUE  THEN 1 ELSE 0 END)::int AS read
      FROM notifications
      WHERE user_id = @uid
      ''',
      parameters: QueryParameters.named({'uid': userId}),
    );

    if (rows.isEmpty) return {'unread': 0, 'read': 0};

    final map = rows.first.toColumnMap();
    return {
      'unread': (map['unread'] as int?) ?? 0,
      'read': (map['read'] as int?) ?? 0,
    };
  }

  // 4. Get By ID (Accepts userId for security check)
  Future<NotificationInfo?> getNotificationById(
      Session session, {
        required int notificationId,
        required int userId, // <--- Added parameter
      }) async {
    final rows = await session.db.unsafeQuery(
      '''
      SELECT notification_id, user_id, title, message, is_read, created_at
      FROM notifications
      WHERE notification_id = @nid AND user_id = @uid
      LIMIT 1
      ''',
      parameters: QueryParameters.named({'nid': notificationId, 'uid': userId}),
    );

    if (rows.isEmpty) return null;

    final m = rows.first.toColumnMap();
    return NotificationInfo(
      notificationId: m['notification_id'] as int,
      userId: m['user_id'] as int,
      title: (m['title'] as String?) ?? '',
      message: (m['message'] as String?) ?? '',
      isRead: (m['is_read'] as bool?) ?? false,
      createdAt: m['created_at'] as DateTime,
    );
  }

  // 5. Mark One Read (Accepts userId)
  Future<bool> markAsRead(
      Session session, {
        required int notificationId,
        required int userId, // <--- Added parameter
      }) async {
    try {
      await session.db.unsafeExecute(
        '''
        UPDATE notifications
        SET is_read = TRUE
        WHERE notification_id = @nid AND user_id = @uid
        ''',
        parameters: QueryParameters.named({'nid': notificationId, 'uid': userId}),
      );
      return true;
    } catch (e, st) {
      session.log(
        'markAsRead failed: $e',
        level: LogLevel.error,
        stackTrace: st,
      );
      return false;
    }
  }

  // 6. Mark All Read (Accepts userId)
  Future<bool> markAllAsRead(
      Session session, {
        required int userId, // <--- Added parameter
      }) async {
    try {
      await session.db.unsafeExecute(
        '''
        UPDATE notifications
        SET is_read = TRUE
        WHERE user_id = @uid AND is_read = FALSE
        ''',
        parameters: QueryParameters.named({'uid': userId}),
      );
      return true;
    } catch (e, st) {
      session.log(
        'markAllAsRead failed: $e',
        level: LogLevel.error,
        stackTrace: st,
      );
      return false;
    }
  }
}