import 'package:flutter_test/flutter_test.dart';
import 'package:hism_management_system/services/supabase_service.dart';

void main() {
  group('SupabaseService profile checks', () {
    final service = SupabaseService();

    test('allows access when profile deleted is 0', () {
      final profile = {'deleted': 0, 'role': 'admin'};

      expect(service.canAccessProfile(profile), isTrue);
      expect(service.resolveRole(profile), 'admin');
    });

    test('denies access when profile deleted is not 0', () {
      final profile = {'deleted': 1, 'role': 'viewer'};

      expect(service.canAccessProfile(profile), isFalse);
      expect(service.resolveRole(profile), 'viewer');
    });
  });
}
