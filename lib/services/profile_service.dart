import 'package:hism_management_system/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class ProfileService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Profile>> fetchProfiles() async {
    final query = _client.from('profiles').select('*').eq('deleted', 0);

    final response = await query;
    final rows = (response as List).cast<Map<String, dynamic>>();
    return rows.map(Profile.fromMap).toList();
  }

  Future<void> updateProfile({
    required String id,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _client.functions.invoke(
      'update_school_user',
      body: {'user_id': id, 'email': email, 'password': password, 'role': role},
    );

    if (response.status != 200) {
      throw Exception(response.data['error'] ?? 'Update failed');
    }
  }

  Future<String> createProfile({
    required String email,
    required String password,
    required String role,
  }) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _client.functions.invoke(
          'create_user_profile',
          body: {'email': email, 'password': password, 'role': role},
        );

        final rawData = response.data;
        final Map<String, dynamic> payload;
        if (rawData is String) {
          payload = jsonDecode(rawData) as Map<String, dynamic>;
        } else if (rawData is Map<String, dynamic>) {
          payload = rawData;
        } else if (rawData is Map) {
          payload = Map<String, dynamic>.from(rawData);
        } else {
          throw Exception(
            'Unexpected Edge Function response format: ${rawData.runtimeType}',
          );
        }

        if (payload.containsKey('error')) {
          final errorMessage =
              payload['error']?.toString() ?? 'Unknown Edge Function error.';
          throw Exception(errorMessage);
        }

        final possibleKeys = ['profile_id', 'id', 'user_id', 'parent_id'];
        String? createdId;
        for (final k in possibleKeys) {
          final v = payload[k]?.toString();
          if (v != null && v.isNotEmpty) {
            createdId = v;
            break;
          }
        }

        if (createdId == null) {
          final functionName = 'create_school_user';
          final createdAt = payload['created_at']?.toString();
          throw Exception(
            'Unable to create profile through Edge Function. Function: $functionName. created_at: ${createdAt ?? 'n/a'}.',
          );
        }

        return createdId;
      } catch (error) {
        final message = error.toString().toLowerCase();
        final isRateLimit =
            message.contains('rate limit') ||
            message.contains('too many requests');
        if (attempt == 2 || !isRateLimit) {
          rethrow;
        }
      }
    }

    throw Exception('Unable to create profile after multiple attempts.');
  }

  Future<void> deleteProfile(String studentId) async {}
}
