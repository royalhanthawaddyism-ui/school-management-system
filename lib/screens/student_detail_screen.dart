import 'package:flutter/material.dart';
import 'package:hism_management_system/controllers/student_controller.dart';
import 'package:hism_management_system/models/student.dart';
import 'package:hism_management_system/services/student_service.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key, required this.student});

  final Student student;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(student.name.isNotEmpty ? student.name : 'Student Details'),
        actions: [
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: student.photoUrl.isNotEmpty
                    ? NetworkImage(student.photoUrl)
                    : null,
                child: student.photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 36)
                    : null,
              ),
              const SizedBox(height: 24),
              Text(
                student.name.isNotEmpty ? student.name : 'Unnamed student',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _InfoRow(
                label: 'Name',
                value: student.name.isNotEmpty ? student.name : 'N/A',
              ),
              _InfoRow(
                label: 'Student ID',
                value: student.studentId.isNotEmpty ? student.studentId : 'N/A',
              ),
              _InfoRow(
                label: 'Year',
                value: student.year.isNotEmpty ? student.year : 'N/A',
              ),
              _InfoRow(
                label: 'D.O.B',
                value: student.dob.isNotEmpty
                    ? StudentController.formatDate(student.dob)
                    : 'N/A',
              ),
              _InfoRow(
                label: 'Address',
                value: student.address.isNotEmpty ? student.address : 'N/A',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
