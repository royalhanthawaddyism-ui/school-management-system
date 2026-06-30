import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hism_management_system/models/student.dart';
import 'package:hism_management_system/screens/student_detail_screen.dart';

void main() {
  testWidgets('shows student id on detail screen', (tester) async {
    final student = Student(
      studentId: 'ST-001',
      name: 'Aye Aye',
      parentName: 'Maung Maung',
      year: 'Grade 4',
      photoUrl: '',
    );

    await tester.pumpWidget(
      MaterialApp(home: StudentDetailScreen(student: student)),
    );

    expect(find.text('Student ID'), findsOneWidget);
    expect(find.text('ST-001'), findsOneWidget);
  });
}
