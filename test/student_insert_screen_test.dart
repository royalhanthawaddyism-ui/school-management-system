import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hism_management_system/screens/student_insert_screen.dart';

void main() {
  testWidgets('Date of birth field uses a calendar picker', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StudentInsertScreen()));

    final dobField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Date of Birth',
      ),
    );

    expect(dobField.readOnly, isTrue);
    expect(dobField.onTap, isNotNull);
    expect(dobField.decoration?.suffixIcon, isA<IconButton>());
  });
}
