// services/announcement_service.dart
import 'package:hism_management_system/models/announcement.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementService {
  final supabase = Supabase.instance.client;

  Stream<List<Announcement>> getAnnouncementsStream() {
    return supabase
        .from('announcements')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => Announcement.fromMap(map)).toList());
  }

  Future<int?> getUserRole(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      return response['role'] as int?;
    } catch (e) {
      return null;
    }
  }

  Future<void> createAnnouncement({
    required String title,
    required String body,
    required String targetType,
    String? targetId,
  }) async {
    final adminId = supabase.auth.currentUser?.id;
    
    await supabase.from('announcements').insert({
      'title': title,
      'body': body,
      'target_type': targetType,
      'target_id': targetId,
      'admin_id': adminId,
    });
  }
}