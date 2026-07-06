import 'package:flutter/material.dart';
import 'package:hism_management_system/controllers/student_controller.dart';
import 'package:hism_management_system/models/student.dart';
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
  late final Student student = widget.student;
  bool _isDeleting = false;

  Future<void> _deleteStudent() async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

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
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.role == '1';

    return Scaffold(
      backgroundColor: Colors.grey[200], // Background color behind the card
      appBar: AppBar(
        title: Text(student.name.isNotEmpty ? student.name : 'Student Details'),
        actions: [
          if (canEdit)
            IconButton(
              tooltip: 'Update student',
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
              constraints: const BoxConstraints(
                maxWidth: 450,
              ), // Responsive limit
              child: AspectRatio(
                aspectRatio: 9 / 16, // Matches the template aspect ratio
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

                      // Dynamic styling based on card scale
                      final textStyle = TextStyle(
                        fontSize: width * 0.04,
                        color: const Color(
                          0xFF0D2569,
                        ), // Matches the template theme
                        fontWeight: FontWeight.w600,
                      );

                      return Stack(
                        children: [
                          // 1. Template Background Image
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/student.png', // Ensure this matches your asset path
                              fit: BoxFit.cover,
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

                          // 3. Information Fields Overlay
                          // Positioned neatly directly on top of the blank template lines
                          Positioned(
                            left: width * 0.42,
                            right: width * 0.12,
                            top: height * 0.587,
                            bottom: height * 0.14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTextLine(
                                  student.name.isNotEmpty
                                      ? student.name
                                      : 'N/A',
                                  textStyle,
                                ),
                                _buildTextLine(
                                  student.studentId.isNotEmpty
                                      ? student.studentId
                                      : 'N/A',
                                  textStyle,
                                ),
                                _buildTextLine(
                                  student.year.isNotEmpty
                                      ? student.year
                                      : 'N/A',
                                  textStyle,
                                ),
                                _buildTextLine(
                                  student.dob.isNotEmpty
                                      ? StudentController.formatDate(
                                          student.dob,
                                        )
                                      : 'N/A',
                                  textStyle,
                                ),
                                _buildTextLine(
                                  student.address.isNotEmpty
                                      ? student.address
                                      : 'N/A',
                                  textStyle,
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
    );
  }

  Widget _buildTextLine(String value, TextStyle style) {
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
