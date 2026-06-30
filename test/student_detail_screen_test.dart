import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hism_management_system/models/student.dart';
import 'package:hism_management_system/screens/student_detail_screen.dart';

void main() {
  testWidgets('shows the student details on the detail screen', (tester) async {
    final student = Student(
      studentId: 'ST-001',
      name: 'Aye Aye',
      parentName: 'Maung Maung',
      year: 'Grade 4',
      dob: '12/03/2014',
      address: 'No. 10, Main Street',
      photoUrl: '',
    );

    await tester.pumpWidget(
      MaterialApp(home: StudentDetailScreen(student: student)),
    );

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Aye Aye'), findsWidgets);
    expect(find.text('Student ID'), findsOneWidget);
    expect(find.text('ST-001'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Grade 4'), findsOneWidget);
    expect(find.text('D.O.B'), findsOneWidget);
    expect(find.text('12/03/2014'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('No. 10, Main Street'), findsOneWidget);
  });
}
