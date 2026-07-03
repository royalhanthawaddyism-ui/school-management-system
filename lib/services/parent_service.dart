import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/models/parent.dart';

class ParentService {
  SupabaseClient get _client => Supabase.instance.client;

  String get defaultParentPassword => 'parent';

  String buildParentAuthEmail(Parent parent) {
    final phoneDigits = parent.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final seed = phoneDigits.isNotEmpty
        ? phoneDigits
        : [parent.fatherName, parent.motherName]
              .join(' ')
              .trim()
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
              .replaceAll(RegExp(r'^_|_$'), '');

    final baseSeed = seed.isEmpty ? 'parent' : 'parent_$seed';
    final uniqueSuffix = DateTime.now().microsecondsSinceEpoch.toString();
    // Append a domain so the generated value is a valid email address.
    return '$baseSeed$uniqueSuffix@example.com';
  }

  Future<String> createParent(Parent parent) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final email = buildParentAuthEmail(parent);
        final response = await _client.functions.invoke(
          'create_school_user',
          body: {
            'father_name': parent.fatherName,
            'mother_name': parent.motherName,
            'phone': parent.phone,
            'address': parent.address,
            'email': email,
            'password': defaultParentPassword,
          },
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

        final parentId = payload['parent_id']?.toString();
        if (parentId == null || parentId.isEmpty) {
          final functionName = 'create_school_user';
          final createdAt = payload['created_at']?.toString();
          throw Exception(
            'Unable to create parent account through Edge Function. '
            'Function: $functionName. created_at: ${createdAt ?? 'n/a'}.',
          );
        }

        final createdEmail = payload['email']?.toString();
        if (createdEmail != null && createdEmail.isNotEmpty) {
          debugPrint('Created parent auth email: $createdEmail');
        }

        return parentId;
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

    throw Exception('Unable to create parent account after multiple attempts.');
  }

  Future<void> deleteParentById(String id) async {
    await _client.from('parents').update({'deleted': 1}).eq('id', id);
  }

  Future<String?> getParentIdByProfileId(String profileId) async {
    final response = await _client
        .from('parents')
        .select('id')
        .eq('profile_id', profileId)
        .eq('deleted', 0)
        .maybeSingle();

    return response?['id']?.toString();
  }

  Future<List<Parent>> searchParents(String query) async {
    final builder = _client
        .from('parents')
        .select('id, father_name, mother_name, phone, address')
        .eq('deleted', 0);
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      final sanitizedQuery = trimmedQuery.replaceAll("'", "''");
      builder.or(
        'father_name.ilike.%$sanitizedQuery%,mother_name.ilike.%$sanitizedQuery%,phone.ilike.%$sanitizedQuery%',
      );
    }
    final response = await builder.order('father_name');
    final rows = (response as List).cast<Map<String, dynamic>>();
    return rows.map(Parent.fromMap).toList();
  }

  Future<List<Parent>> fetchAllParents() async {
    final response = await _client
        .from('parents')
        .select('id, father_name, mother_name, phone, address')
        .eq('deleted', 0)
        .order('father_name', ascending: true);
    final rows = (response as List).cast<Map<String, dynamic>>();
    return rows.map(Parent.fromMap).toList();
  }
}
