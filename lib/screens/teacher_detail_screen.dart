import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:hism_management_system/models/teacher.dart';
import 'package:hism_management_system/services/teacher_service.dart';

class TeacherDetailScreen extends StatefulWidget {
  const TeacherDetailScreen({
    super.key,
    required this.teacher,
    required this.role,
  });

  final Teacher teacher;
  final String role;

  @override
  State<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  late final Teacher teacher = widget.teacher;
  bool _isDeleting = false;
  bool _isSavingImage = false;

  final GlobalKey _globalKey = GlobalKey();

  Future<void> _deleteTeacher() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    try {
      await TeacherService().deleteTeacher(teacher.employeeId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher deleted successfully.')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete teacher: $error')),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _saveCardAsImage() async {
    if (_isSavingImage) return;
    setState(() => _isSavingImage = true);

    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }

      final RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        await Gal.putImageBytes(pngBytes, album: 'Teacher IDs');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teacher ID Card saved to gallery successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.role == '1';

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(teacher.name.isNotEmpty ? teacher.name : 'Teacher Details'),
        actions: [
          IconButton(
            tooltip: 'Save card as image',
            icon: _isSavingImage
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_alt),
            onPressed: _isSavingImage ? null : _saveCardAsImage,
          ),
          if (canEdit)
            IconButton(
              tooltip: 'Update teacher',
              icon: const Icon(Icons.edit),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Update flow is not implemented yet.'),
                  ),
                );
              },
            ),
          if (canEdit)
            IconButton(
              tooltip: 'Delete teacher',
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete),
              onPressed: _isDeleting ? null : _deleteTeacher,
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Card(
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;

                        final nameStyle = TextStyle(
                          fontSize: width * 0.055,
                          color: const Color(0xFF0D2569),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        );

                        final valueStyle = TextStyle(
                          fontSize: width * 0.038,
                          color: const Color(0xFF0D2569),
                          fontWeight: FontWeight.w700,
                        );

                        return Stack(
                          children: [
                            // ၁။ Background ID Card Template ပုံ
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/teacher.png',
                                fit: BoxFit.cover,
                              ),
                            ),

                            Positioned(
                              top: height * 0.22,
                              left: width * 0.24,
                              right: width * 0.12,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage:
                                      teacher.photoUrl != null &&
                                          teacher.photoUrl!.isNotEmpty
                                      ? NetworkImage(teacher.photoUrl!)
                                      : null,
                                  child:
                                      teacher.photoUrl == null ||
                                          teacher.photoUrl!.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: width * 0.25,
                                          color: Colors.grey[600],
                                        )
                                      : null,
                                ),
                              ),
                            ),

                            Positioned(
                              left: width * 0.24,
                              right: width * 0.10,
                              top: height * 0.65,
                              child: Text(
                                teacher.name.toUpperCase(),
                                style: nameStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            Positioned(
                              left: width * 0.54,
                              right: width * 0.06,
                              top: height * 0.793,
                              bottom: height * 0.065,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildTeacherValue(
                                    teacher.employeeId.isNotEmpty
                                        ? teacher.employeeId
                                        : 'N/A',
                                    valueStyle,
                                  ),
                                  _buildTeacherValue(
                                    teacher.subject.isNotEmpty
                                        ? teacher.subject
                                        : 'N/A',
                                    valueStyle,
                                  ),
                                  _buildTeacherValue(
                                    teacher.formattedJoiningDate,
                                    valueStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherValue(String value, TextStyle style) {
    return Expanded(
      child: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
