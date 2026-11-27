import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        'content':
            'This long message should wrap within a two-thirds-width bubble '
            'without stretching across the full screen.',
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

  @override
  String? resolveImageUrl({String? imageUrl, String? imagePath}) => imageUrl;

  @override
  Future<Uint8List> downloadImage({
    String? imageUrl,
    String? imagePath,
  }) async => Uint8List(0);
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

  testWidgets('long-pressing message text copies it and confirms', (
    tester,
  ) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: GroupChatScreen(service: _FakeGroupChatService())),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('My message'));
    await tester.pumpAndSettle();

    expect(copiedText, 'My message');
    expect(find.text('Copied to clipboard'), findsOneWidget);
  });

  testWidgets('message bubbles are capped at two-thirds screen width', (
    tester,
  ) async {
    const longContent =
        'This long message should wrap within a two-thirds-width bubble '
        'without stretching across the full screen.';
    await tester.pumpWidget(
      MaterialApp(home: GroupChatScreen(service: _FakeGroupChatService())),
    );
    await tester.pumpAndSettle();

    final maxBubbleWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio * (2 / 3);
    final longMessageCard = find.ancestor(
      of: find.text(longContent),
      matching: find.byType(Card),
    );
    final shortMessageCard = find.ancestor(
      of: find.text('My message'),
      matching: find.byType(Card),
    );

    expect(
      tester.getSize(longMessageCard).width,
      lessThanOrEqualTo(maxBubbleWidth),
    );
    expect(tester.getSize(shortMessageCard).width, lessThan(maxBubbleWidth));
    expect(
      tester.getSize(find.text(longContent)).height,
      greaterThan(tester.getSize(find.text('My message')).height),
    );
  });
}
