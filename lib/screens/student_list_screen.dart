import 'package:flutter/material.dart';
import 'package:hism_management_system/controllers/student_controller.dart';
import 'package:hism_management_system/models/student.dart';
import 'package:hism_management_system/screens/student_detail_screen.dart';
import 'package:hism_management_system/screens/student_insert_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StudentController _controller = StudentController();
  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<List<Student>> _fetchStudents() async {
    return _controller.fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const StudentInsertScreen()),
          ).then((shouldRefresh) {
            if (shouldRefresh == true) {
              setState(() {
                _studentsFuture = _fetchStudents();
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by student ID or name',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Student>>(
                future: _studentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Unable to load students: ${snapshot.error}'),
                    );
                  }

                  final students = snapshot.data ?? [];
                  final filteredStudents = _controller.filterStudents(
                    students,
                    _searchController.text,
                  );

                  if (filteredStudents.isEmpty) {
                    return const Center(child: Text('No students found.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: filteredStudents.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    StudentDetailScreen(student: student),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            backgroundImage: student.photoUrl.isNotEmpty
                                ? NetworkImage(student.photoUrl)
                                : null,
                            child: student.photoUrl.isEmpty
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                          title: Text(
                            student.name.isNotEmpty
                                ? student.name
                                : 'Unnamed student',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Student ID: ${student.studentId.isNotEmpty ? student.studentId : 'N/A'}',
                              ),
                              Text(
                                'Year: ${student.year.isNotEmpty ? student.year : 'N/A'}',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
