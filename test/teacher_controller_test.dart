import 'package:flutter_test/flutter_test.dart';
import 'package:hism_management_system/controllers/teacher_controller.dart';
import 'package:hism_management_system/models/teacher.dart';

void main() {
  test('Teacher.fromJson keeps phone and address values', () {
    final teacher = Teacher.fromJson({
      'id': 1,
      'employee_id': 'T001',
      'name': 'Jane Doe',
      'photo_url': 'https://example.com/photo.jpg',
      'subject': 'Mathematics',
      'dob': '1992-05-10',
      'gender': 'Female',
      'phone': '1234567890',
      'address': 'Yangon',
      'joining_date': '2020-01-05',
    });

    expect(teacher.phone, '1234567890');
    expect(teacher.address, 'Yangon');
  });

  test('populateFromTeacher pre-fills controller fields for editing', () {
    final controller = TeacherController();
    final teacher = Teacher(
      employeeId: 'T001',
      name: 'Jane Doe',
      subject: 'Mathematics',
      dob: DateTime(1992, 5, 10),
      gender: 'Female',
      phone: '1234567890',
      address: 'Yangon',
      joiningDate: DateTime(2020, 1, 5),
      photoUrl: 'https://example.com/photo.jpg',
    );

    controller.populateFromTeacher(teacher);

    expect(controller.employeeIdController.text, 'T001');
    expect(controller.nameController.text, 'Jane Doe');
    expect(controller.subjectController.text, 'Mathematics');
    expect(controller.phoneController.text, '1234567890');
    expect(controller.addressController.text, 'Yangon');
    expect(controller.selectedGender, 'Female');
    expect(controller.selectedDob, teacher.dob);
    expect(controller.selectedJoiningDate, teacher.joiningDate);
    expect(controller.existingPhotoUrl, teacher.photoUrl);

    controller.dispose();
  });
}
