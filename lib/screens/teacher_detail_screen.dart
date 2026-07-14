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

                        const primaryColor = Color(0xFF0D2569);

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/teacher.png',
                                fit: BoxFit.cover,
                              ),
                            ),

                            Positioned(
                              top: height * 0.08,
                              left: width * 0.00,
                              right: width * 0.07,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "ROYAL",
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),

                                  Transform.translate(
                                    offset: Offset(0, -height * 0.01),
                                    child: Text(
                                      "HANTHAWADDY",
                                      style: TextStyle(
                                        fontSize: width * 0.062,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),

                                  Transform.translate(
                                    offset: Offset(0, -height * 0.02),
                                    child: Text(
                                      "INTERNATIONAL SCHOOL MYANMAR",
                                      style: TextStyle(
                                        fontSize: width * 0.018,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              left: -width * 0.03,
                              top: height * 0.17,
                              bottom: height * 0.25,
                              child: Container(
                                alignment: Alignment.center,
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    "TEACHER",
                                    style: TextStyle(
                                      fontSize: width * 0.16,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 6.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              left: width * 0.23,
                              right: width * 0.05,
                              bottom: height * 0.3,
                              child: AspectRatio(
                                aspectRatio: 3 / 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    image:
                                        teacher.photoUrl != null &&
                                            teacher.photoUrl!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              teacher.photoUrl!,
                                            ),
                                            fit: BoxFit.contain,
                                          )
                                        : null,
                                  ),
                                  child:
                                      teacher.photoUrl == null ||
                                          teacher.photoUrl!.isEmpty
                                      ? Center(
                                          child: Icon(
                                            Icons.person,
                                            size: width * 0.25,
                                            color: Colors.grey[400],
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),

                            Positioned(
                              left: width * 0.24,
                              right: width * 0.03,
                              top: height * 0.74,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Expanded(
                                    child: Divider(
                                      color: Color(0xFFE48224),
                                      thickness: 1.5,
                                      endIndent: 10,
                                    ),
                                  ),
                                  Text(
                                    "TEACHER",
                                    style: TextStyle(
                                      fontSize: width * 0.045,
                                      color: const Color(0xFFE48224),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      color: Color(0xFFE48224),
                                      thickness: 1.5,
                                      indent: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              left: width * 0.26,
                              right: width * 0.05,
                              top: height * 0.7,
                              child: Container(
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    teacher.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: width * 0.06,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              left: width * 0.3,
                              right: width * 0.04,
                              top: height * 0.792,
                              bottom: height * 0.065,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDataRow(
                                    "EMPLOYEE ID",
                                    teacher.employeeId.isNotEmpty
                                        ? teacher.employeeId
                                        : 'N/A',
                                    width,
                                    primaryColor,
                                  ),
                                  _buildDataRow(
                                    "SUBJECT",
                                    teacher.subject.isNotEmpty
                                        ? teacher.subject
                                        : 'N/A',
                                    width,
                                    primaryColor,
                                  ),
                                  _buildDataRow(
                                    "JOINING DATE",
                                    teacher.formattedJoiningDate,
                                    width,
                                    primaryColor,
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

  Widget _buildDataRow(
    String label,
    String value,
    double cardWidth,
    Color textColor,
  ) {
    return Expanded(
      child: Row(
        children: [
          SizedBox(
            width: cardWidth * 0.28,
            child: Text(
              label,
              style: TextStyle(
                fontSize: cardWidth * 0.04,
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          Text(
            ":",
            style: TextStyle(
              fontSize: cardWidth * 0.04,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: cardWidth * 0.04),

          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: cardWidth * 0.04,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
