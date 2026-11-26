import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hism_management_system/screens/group_chat_screen.dart';
import 'package:hism_management_system/services/group_chat_service.dart';

class _FakeGroupChatService implements GroupChatService {
  @override
  Stream<List<Map<String, dynamic>>> watchMessages() {
    return Stream.value([
      {
        'content': 'This message stays visible',
        'image_deleted': true,
        'image_url': 'https://example.com/expired-photo.jpg',
      },
    ]);
  }

  @override
  Future<void> sendMessage({String? text, Uint8List? imageBytes}) async {}
}

void main() {
  testWidgets('deleted photos show a notice without loading their URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: GroupChatScreen(service: _FakeGroupChatService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('This message stays visible'), findsOneWidget);
    expect(find.text('Photo removed after 14 days'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is NetworkImage,
      ),
      findsNothing,
    );
  });
}
