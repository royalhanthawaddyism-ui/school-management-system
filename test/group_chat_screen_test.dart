import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hism_management_system/screens/group_chat_screen.dart';
import 'package:hism_management_system/services/group_chat_service.dart';

class _FakeGroupChatService implements GroupChatService {
  @override
  String? get currentUserId => 'current-user';

  @override
  Stream<List<Map<String, dynamic>>> watchMessages() {
    return Stream.value([
      {
        'content': 'Another message from them',
        'image_deleted': false,
        'sender_email': 'other@hism.school',
        'sender_id': 'other-user',
      },
      {
        'content': 'This message stays visible',
        'image_deleted': true,
        'image_url': 'https://example.com/expired-photo.jpg',
        'sender_email': 'other@hism.school',
        'sender_id': 'other-user',
      },
      {
        'content': 'My message',
        'image_deleted': false,
        'sender_email': 'me@hism.school',
        'sender_id': 'current-user',
      },
      {
        'content': 'Their message',
        'image_deleted': false,
        'sender_email': null,
        'sender_id': 'other-user',
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
    expect(find.text('other'), findsOneWidget);
    expect(find.text('me'), findsNothing);
    expect(find.text('Unknown'), findsOneWidget);
    expect(find.text('Another message from them'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('My message'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Align && widget.alignment == Alignment.centerRight,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.text('Their message'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Align && widget.alignment == Alignment.centerLeft,
        ),
      ),
      findsOneWidget,
    );
  });
}
