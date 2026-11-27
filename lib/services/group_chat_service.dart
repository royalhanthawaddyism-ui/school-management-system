import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupChatService {
  GroupChatService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static const String _bucketName = 'group-images';

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Stream<List<Map<String, dynamic>>> watchMessages() {
    return _client
        .from('group_messages')
        .stream(primaryKey: ['id'])
        .eq('deleted', 0)
        .order('created_at', ascending: true)
        .map((rows) => rows.cast<Map<String, dynamic>>());
  }

  Future<void> sendMessage({String? text, Uint8List? imageBytes}) async {
    final trimmedText = text?.trim();
    final hasText = trimmedText != null && trimmedText.isNotEmpty;
    final hasImage = imageBytes != null;

    if (!hasText && !hasImage) {
      throw ArgumentError('A message must include text, an image, or both.');
    }
    if (hasImage && imageBytes.isEmpty) {
      throw ArgumentError.value(imageBytes, 'imageBytes', 'Must not be empty.');
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('An authenticated user is required to send a message.');
    }
    final senderId = user.id;

    String? imageUrl;
    String? imagePath;
    String? imageExpiresAt;
    if (imageBytes != null) {
      final compressedImageBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: 1280,
        minHeight: 1280,
        quality: 75,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      if (compressedImageBytes.isEmpty) {
        throw StateError('Image compression produced an empty file.');
      }

      final storagePath = _createImagePath();
      await _client.storage
          .from(_bucketName)
          .uploadBinary(
            storagePath,
            compressedImageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      imagePath = storagePath;
      imageUrl = _client.storage.from(_bucketName).getPublicUrl(storagePath);
      imageExpiresAt = DateTime.now()
          .toUtc()
          .add(const Duration(days: 14))
          .toIso8601String();
    }

    await _client.from('group_messages').insert({
      'sender_id': senderId,
      'sender_email': user.email,
      'content': hasText ? trimmedText : null,
      'image_path': imagePath,
      'image_url': imageUrl,
      'image_expires_at': imageExpiresAt,
      'image_deleted': false,
      'deleted': 0,
    });
  }

  String _createImagePath() {
    final randomPart = Random.secure().nextInt(1 << 32).toRadixString(16);
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    return '$timestamp-$randomPart.jpg';
  }
}
