import 'package:hism_management_system/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Profile>> fetchProfiles() async {
    final query = _client.from('profiles').select('*').eq('deleted', 0);

    final response = await query;
    final rows = (response as List).cast<Map<String, dynamic>>();
    return rows.map(Profile.fromMap).toList();
  }

  Future<void> deleteProfile(String studentId) async {}
}
