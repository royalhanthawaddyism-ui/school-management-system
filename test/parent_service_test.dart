import 'package:flutter_test/flutter_test.dart';
import 'package:hism_management_system/models/parent.dart';
import 'package:hism_management_system/services/parent_service.dart';

void main() {
  group('ParentService account helpers', () {
    final service = ParentService();

    test('builds a non-email parent identity from parent details', () {
      final parent = Parent(
        id: '',
        fatherName: 'John',
        motherName: 'Jane',
        phone: '+255712345678',
        address: 'Dar es Salaam',
      );

      final identity = service.buildParentAuthEmail(parent);

      expect(identity, startsWith('parent_'));
      expect(identity, isNot(contains('@gmail.com')));
      expect(identity, contains('255712345678'));
    });

    test('uses the default password for parent auth accounts', () {
      expect(service.defaultParentPassword, 'parent');
    });
  });
}
