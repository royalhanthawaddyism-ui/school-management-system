import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient get client => Supabase.instance.client;

  bool canAccessProfile(Map<String, dynamic>? profile) {
    final deleted = profile?['deleted'];
    return deleted == 0;
  }

  String resolveRole(Map<String, dynamic>? profile) {
    final role = profile?['role'];
    if (role is String && role.isNotEmpty) {
      return role;
    }
    return 'user';
  }

  Future<Map<String, dynamic>?> getProfileByUserId(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final authResponse = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = authResponse.user?.id;
    if (userId == null) {
      throw Exception('Unable to get authenticated user.');
    }

    final profile = await getProfileByUserId(userId);
    if (!canAccessProfile(profile)) {
      throw Exception('Access denied for this user profile.');
    }

    return profile;
  }
}
