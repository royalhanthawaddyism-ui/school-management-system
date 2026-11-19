// controllers/announcement_controller.dart
import 'package:hism_management_system/models/announcement.dart';
import '../services/announcement_service.dart';

class AnnouncementController {
  final AnnouncementService _service = AnnouncementService();

  Stream<List<Announcement>> fetchAnnouncements() {
    return _service.getAnnouncementsStream();
  }

Future<bool> checkIsAdmin() async {
    final userId = _service.supabase.auth.currentUser?.id;
    if (userId == null) return false;
    
    int? role = await _service.getUserRole(userId);
    return role == 1; // role = 1 ဖြစ်မှသာ Admin
  }

  Future<void> submitAnnouncement({
    required String title,
    required String body,
    required String targetType,
    String? targetId,
  }) async {
    await _service.createAnnouncement(
      title: title,
      body: body,
      targetType: targetType,
      targetId: targetId,
    );
  }
}