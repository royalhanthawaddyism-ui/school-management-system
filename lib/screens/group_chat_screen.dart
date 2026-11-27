import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:hism_management_system/services/group_chat_service.dart';
import 'package:image_picker/image_picker.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key, this.service});

  final GroupChatService? service;

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  late final GroupChatService _service;
  late final Stream<List<Map<String, dynamic>>> _messagesStream;

  Uint8List? _selectedImageBytes;
  bool _isSending = false;
  final Set<String> _downloadingImageKeys = {};

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? GroupChatService();
    _messagesStream = _service.watchMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImageBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to choose photo: $error');
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    final imageBytes = _selectedImageBytes;
    if (_isSending || (text.isEmpty && imageBytes == null)) return;

    setState(() => _isSending = true);
    try {
      await _service.sendMessage(text: text, imageBytes: imageBytes);
      if (!mounted) return;
      _textController.clear();
      setState(() {
        _selectedImageBytes = null;
      });
    } catch (error) {
      debugPrint('Unable to send group chat message: $error');
      if (!mounted) return;
      _showMessage('Unable to send message: $error');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _downloadImage({
    required String imageKey,
    String? imageUrl,
    String? imagePath,
  }) async {
    if (_downloadingImageKeys.contains(imageKey)) return;
    setState(() => _downloadingImageKeys.add(imageKey));

    try {
      final imageBytes = await _service.downloadImage(
        imageUrl: imageUrl,
        imagePath: imagePath,
      );
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }
      await Gal.putImageBytes(imageBytes, album: 'Group Chat');

      if (!mounted) return;
      _showMessage('Image saved to gallery.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to save image: $error');
    } finally {
      if (mounted) {
        setState(() => _downloadingImageKeys.remove(imageKey));
      }
    }
  }

  Widget _buildMessage(
    Map<String, dynamic> message, {
    required bool isMe,
    required bool showSenderName,
  }) {
    final content = message['content']?.toString().trim() ?? '';
    final imageDeleted = message['image_deleted'];
    final imageUrl = message['image_url']?.toString();
    final imagePath = message['image_path']?.toString();
    final resolvedImageUrl = _service.resolveImageUrl(
      imageUrl: imageUrl,
      imagePath: imagePath,
    );
    final imageKey = imagePath?.trim().isNotEmpty == true
        ? 'path:${imagePath!.trim()}'
        : 'url:${resolvedImageUrl ?? ''}';
    final isDownloadingImage = _downloadingImageKeys.contains(imageKey);
    final senderEmail = message['sender_email']?.toString();
    final senderName = senderEmail?.replaceAll('@hism.school', '') ?? 'Unknown';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSenderName)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(senderName),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * (2 / 3),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (content.isNotEmpty)
                      GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: content));
                          _showMessage('Copied to clipboard');
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(content),
                        ),
                      ),
                    if (imageDeleted == true)
                      const Text(
                        'Photo removed after 14 days',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      )
                    else if (resolvedImageUrl != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              resolvedImageUrl,
                              width: 240,
                              height: 240,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const SizedBox(
                                  width: 240,
                                  height: 180,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    width: 240,
                                    height: 80,
                                    child: Center(
                                      child: Text('Photo unavailable'),
                                    ),
                                  ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                tooltip: 'Save image to gallery',
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 36,
                                  height: 36,
                                ),
                                onPressed: isDownloadingImage
                                    ? null
                                    : () => _downloadImage(
                                        imageKey: imageKey,
                                        imageUrl: imageUrl,
                                        imagePath: imagePath,
                                      ),
                                icon: isDownloadingImage
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.download,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedImageBytes != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _selectedImageBytes!,
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 28,
                              height: 28,
                            ),
                            onPressed: _isSending
                                ? null
                                : () {
                                    setState(() {
                                      _selectedImageBytes = null;
                                    });
                                  },
                            icon: const Icon(Icons.cancel, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Choose photo',
                    onPressed: _isSending ? null : _pickImage,
                    icon: const Icon(Icons.image_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_isSending,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RHISM Community Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Unable to load messages: ${snapshot.error}'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageIndex = messages.length - 1 - index;
                    final message = messages[messageIndex];
                    final messageSenderId = message['sender_id'];
                    final isMe =
                        _service.currentUserId != null &&
                        messageSenderId == _service.currentUserId;
                    final messageAbove = messageIndex > 0
                        ? messages[messageIndex - 1]
                        : null;
                    final showSenderName =
                        !isMe &&
                        (messageAbove == null ||
                            messageAbove['sender_id'] != messageSenderId);

                    return _buildMessage(
                      message,
                      isMe: isMe,
                      showSenderName: showSenderName,
                    );
                  },
                );
              },
            ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }
}
