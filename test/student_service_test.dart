import 'package:flutter_test/flutter_test.dart';
import 'package:hism_management_system/services/student_service.dart';

void main() {
  group('StudentService photo validation', () {
    test('allows photos up to 1 MB', () {
      expect(StudentService.validatePhotoSize(1024 * 1024), isNull);
      expect(StudentService.validatePhotoSize((1024 * 1024) - 1), isNull);
    });

    test('rejects photos larger than 1 MB', () {
      expect(
        StudentService.validatePhotoSize((1024 * 1024) + 1),
        'Photo must be under 1 MB.',
      );
    });
  });

  group('StudentService parent cleanup decision', () {
    test('marks parent cleanup when no other active students use it', () {
      expect(StudentService.shouldDeleteParent(0), isTrue);
    });

    test('keeps parent active when other active students still use it', () {
      expect(StudentService.shouldDeleteParent(1), isFalse);
    });
  });
}
