import 'package:hism_management_system/setup/setupModels/year.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class YearService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Year>> fetchYears() async {
    try {
      final response = await _client
          .from('years')
          .select()
          .eq('deleted', 0)
          .order('id', ascending: true);

      final List<dynamic> data = response;
      return data.map((json) => Year.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch years: $e');
    }
  }

  /// Create a new year entry
  Future<Year> createYear(String name) async {
    try {
      final response = await _client
          .from('years')
          .insert({'name': name, 'deleted': 0})
          .select()
          .single();

      return Year.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create year: $e');
    }
  }

  /// Update an existing year name
  Future<void> updateYear(String id, String newName) async {
    try {
      await _client
          .from('years')
          .update({
            'name': newName,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update year: $e');
    }
  }

  /// Soft delete a year (deleted = 1)
  Future<void> softDeleteYear(String id) async {
    try {
      await _client
          .from('years')
          .update({
            'deleted': 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete year: $e');
    }
  }
}
