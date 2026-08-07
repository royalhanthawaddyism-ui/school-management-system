import 'package:flutter/material.dart';
import 'package:hism_management_system/controllers/teacher_controller.dart';
import 'package:hism_management_system/models/teacher.dart';
import 'package:hism_management_system/screens/teacher_detail_screen.dart';
import 'package:hism_management_system/screens/teacher_insert_update_screen.dart';

class TeacherListScreen extends StatefulWidget {
  final String role;
  const TeacherListScreen({super.key, required this.role});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TeacherController _controller = TeacherController();

  @override
  void initState() {
    super.initState();
    _controller.loadTeachers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teachers'), centerTitle: false),
      floatingActionButton: widget.role == '1'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherInsertScreen(),
                  ),
                ).then((shouldRefresh) {
                  if (shouldRefresh == true) {
                    setState(() {
                      _controller.loadTeachers();
                    });
                  }
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by name or subject',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  if (_controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_controller.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _controller.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _controller.loadTeachers,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredTeachers = _controller.filterTeachers(
                    _controller.teachers,
                    _searchController.text,
                  );

                  if (filteredTeachers.isEmpty) {
                    return const Center(child: Text('No teachers found.'));
                  }

                  return RefreshIndicator(
                    onRefresh: _controller.loadTeachers,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filteredTeachers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final Teacher teacher = filteredTeachers[index];

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              backgroundImage:
                                  teacher.photoUrl != null &&
                                      teacher.photoUrl!.isNotEmpty
                                  ? NetworkImage(teacher.photoUrl!)
                                  : null,
                              child:
                                  teacher.photoUrl == null ||
                                      teacher.photoUrl!.isEmpty
                                  ? Text(
                                      teacher.initials,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              teacher.name.isNotEmpty
                                  ? teacher.name
                                  : 'Unnamed Teacher',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Subject: ${teacher.subject}'),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Joined: ${teacher.formattedJoiningDate}",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TeacherDetailScreen(
                                    teacher: teacher,
                                    role: widget.role,
                                  ),
                                ),
                              ).then((shouldRefresh) {
                                if (shouldRefresh == true) {
                                  _controller.loadTeachers();
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
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
