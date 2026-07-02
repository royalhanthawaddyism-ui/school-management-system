import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/models/parent.dart';

class ParentService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<String> createParent(Parent parent) async {
    final response = await _client
        .from('parents')
        .insert({
          'father_name': parent.fatherName,
          'mother_name': parent.motherName,
          'phone': parent.phone,
          'address': parent.address,
          'deleted': 0,
        })
        .select('id')
        .single();

    return response['id'].toString();
  }

  Future<void> deleteParentById(String id) async {
    await _client.from('parents').update({'deleted': 1}).eq('id', id);
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
