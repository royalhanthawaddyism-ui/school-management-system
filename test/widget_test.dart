// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hism_management_system/models/student.dart';

void main() {
  group('Student list helpers', () {
    test('parses common student fields from Supabase rows', () {
      final student = Student.fromMap({
        'student_id': 'ST-001',
        'student_name': 'Aye Aye',
        'parent_name': 'Maung Maung',
        'year': 'Grade 4',
        'photo_url': 'https://example.com/photo.jpg',
      });

      expect(student.id, 'ST-001');
      expect(student.name, 'Aye Aye');
      expect(student.parentName, 'Maung Maung');
      expect(student.year, 'Grade 4');
      expect(student.photoUrl, 'https://example.com/photo.jpg');
    });

    test('matches search queries across id, name, parent name, and year', () {
      final student = Student.fromMap({
        'student_id': 'ST-001',
        'student_name': 'Aye Aye',
        'parent_name': 'Maung Maung',
        'year': 'Grade 4',
      });

      expect(student.matchesSearch('st-001'), isTrue);
      expect(student.matchesSearch('aye'), isTrue);
      expect(student.matchesSearch('maung'), isTrue);
      expect(student.matchesSearch('grade 4'), isTrue);
      expect(student.matchesSearch('unknown'), isFalse);
    });
  });
}
