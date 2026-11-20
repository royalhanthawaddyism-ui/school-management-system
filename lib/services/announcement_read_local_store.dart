import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementReadLocalStore {
  static String _keyForUser(String userId) => 'last_seen_announcement_$userId';

  Future<DateTime?> getLastSeenAt(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> markAllAsSeen(
    String userId, {
    DateTime? latestTimestamp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final targetTime = (latestTimestamp ?? DateTime.now()).toUtc();
    await prefs.setString(_keyForUser(userId), targetTime.toIso8601String());
  }

  Future<bool> hasUnreadAnnouncements({
    required String userId,
    required List<DateTime> announcementCreatedAts,
  }) async {
    if (announcementCreatedAts.isEmpty) return false;

    final lastSeen = await getLastSeenAt(userId);
    if (lastSeen == null) return true;

    return announcementCreatedAts.any(
      (createdAt) => createdAt.toUtc().isAfter(lastSeen.toUtc()),
    );
  }
}