import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart'; // Crucial for actual storage injection
import 'package:hism_management_system/controllers/student_controller.dart';
import 'package:hism_management_system/models/student.dart';
import 'package:hism_management_system/screens/student_insert_update_screen.dart';
import 'package:hism_management_system/services/student_service.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({
    super.key,
    required this.student,
    required this.role,
  });

  final Student student;
  final String role;

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Student student = widget.student;
  bool _isDeleting = false;
  bool _isSavingImage = false;

  final GlobalKey _globalKey = GlobalKey();

  Future<void> _deleteStudent() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    try {
      await StudentService().deleteStudent(student.studentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully.')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete student: $error')),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // FIXED: Actally saves the byte stream into the device storage directory
  Future<void> _saveCardAsImage() async {
    if (_isSavingImage) return;
    setState(() => _isSavingImage = true);

    try {
      // 1. Request local device storage permissions cleanly
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }

      // 2. Render UI element framework to engine image representation
      final RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // 3. PHYSICAL SAVE ACTION: Writes raw data to the public gallery
        await Gal.putImageBytes(pngBytes, album: 'Student IDs');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID Card saved to gallery successfully!'),
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
        title: Text(student.name.isNotEmpty ? student.name : 'Student Details'),
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
              tooltip: 'Update student',
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updatedStudent = await Navigator.push<Student?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentInsertUpdateScreen(student: student),
                  ),
                );

                if (updatedStudent != null && mounted) {
                  setState(() {
                    student = updatedStudent;
                  });
                }
              },
            ),
          if (canEdit)
            IconButton(
              tooltip: 'Delete student',
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete),
              onPressed: _isDeleting ? null : _deleteStudent,
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

                        final titleStyle = TextStyle(
                          fontSize: width * 0.08,
                          color: const Color(0xFF0D2569),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          height: 1.1,
                        );

                        final textStyle = TextStyle(
                          fontSize: width * 0.038,
                          color: const Color(0xFF0D2569),
                          fontWeight: FontWeight.w700,
                        );

                        return Stack(
                          children: [
                            // 1. Template Background Image
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/student.png',
                                fit: BoxFit.cover,
                              ),
                            ),

                            // NEW: 1.5 Hardcoded Header Title Overlay
                            Positioned(
                              left: width * 0.36,
                              top: height * 0.092,
                              right: width * 0.05,
                              child: Text(
                                "STUDENT'S\nID CARD",
                                style: titleStyle,
                              ),
                            ),

                            // 2. Profile Picture Frame Placement
                            Positioned(
                              top: height * 0.234,
                              left: width * 0.20,
                              right: width * 0.20,
                              child: CircleAvatar(
                                radius: width * 0.29,
                                backgroundColor: Colors.transparent,
                                backgroundImage: student.photoUrl.isNotEmpty
                                    ? NetworkImage(student.photoUrl)
                                    : null,
                                child: student.photoUrl.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: width * 0.25,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),

                            // 3. Information Fields Overlay (With Hardcoded Labels)
                            Positioned(
                              left: width * 0.22,
                              right: width * 0.10,
                              top: height * 0.585,
                              bottom: height * 0.135,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDataRow(
                                    'Name',
                                    student.name.isNotEmpty
                                        ? student.name
                                        : 'N/A',
                                    textStyle,
                                    width,
                                  ),
                                  _buildDataRow(
                                    'Student ID',
                                    student.studentId.isNotEmpty
                                        ? student.studentId
                                        : 'N/A',
                                    textStyle,
                                    width,
                                  ),
                                  _buildDataRow(
                                    'Year Level',
                                    student.year.isNotEmpty
                                        ? student.year
                                        : 'N/A',
                                    textStyle,
                                    width,
                                  ),
                                  _buildDataRow(
                                    'D.O.B',
                                    student.dob.isNotEmpty
                                        ? StudentController.formatDate(
                                            student.dob,
                                          )
                                        : 'N/A',
                                    textStyle,
                                    width,
                                  ),
                                  _buildDataRow(
                                    'Address',
                                    student.address.isNotEmpty
                                        ? student.address
                                        : 'N/A',
                                    textStyle,
                                    width,
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
    TextStyle style,
    double cardWidth,
  ) {
    return Expanded(
      child: Row(
        children: [
          SizedBox(
            width: cardWidth * 0.21,
            child: Text(
              label,
              style: style.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
            ),
          ),
          Text(' :  ', style: style),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: style,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
