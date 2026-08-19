import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hism_management_system/controllers/teacher_attendance_controller.dart';

class TeacherAttendanceAdminView extends StatefulWidget {
  const TeacherAttendanceAdminView({super.key});

  @override
  State<TeacherAttendanceAdminView> createState() =>
      _TeacherAttendanceAdminViewState();
}

class _TeacherAttendanceAdminViewState
    extends State<TeacherAttendanceAdminView> {
  late final TeacherAttendanceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TeacherAttendanceController();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Attendance'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _controller.selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    items: List.generate(12, (index) {
                      int monthNum = index + 1;
                      return DropdownMenuItem(
                        value: monthNum,
                        child: Text(
                          DateFormat('MMMM').format(DateTime(0, monthNum)),
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) _controller.setMonth(val);
                    },
                  ),
                ),
                const SizedBox(width: 6),

                // Year Dropdown
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _controller.selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    items: List.generate(5, (index) {
                      int yearNum = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: yearNum,
                        child: Text(
                          yearNum.toString(),
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) _controller.setYear(val);
                    },
                  ),
                ),
                const SizedBox(width: 6),

                // Search Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () async {
                      await _controller.fetchMonthlyAttendance();
                      if (!mounted || _controller.errorMessage == null) return;
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_controller.errorMessage!)),
                      );
                    },
                    child: const Icon(Icons.search, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ----------------- List View Section -----------------
          Expanded(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _controller.daysInMonth.isEmpty
                ? const Center(
                    child: Text(
                      'Select Month & Year, then click Search button.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _controller.daysInMonth.length,
                    itemBuilder: (context, index) {
                      final currentDay = _controller.daysInMonth[index];
                      final dateKey = DateFormat(
                        'yyyy-MM-dd',
                      ).format(currentDay);
                      final recordsForDay = _controller.attendanceMap[dateKey];

                      final timeFormat = DateFormat('hh:mm a');

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ExpansionTile(
                          title: Text(
                            DateFormat(
                              'dd MMMM yyyy (EEEE)',
                            ).format(currentDay),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            recordsForDay == null || recordsForDay.isEmpty
                                ? 'No Record'
                                : '${recordsForDay.length} Teacher(s) Attended',
                            style: TextStyle(
                              color:
                                  recordsForDay == null || recordsForDay.isEmpty
                                  ? Colors.redAccent
                                  : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: [
                            if (recordsForDay == null || recordsForDay.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'no record',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recordsForDay.length,
                                itemBuilder: (context, recordIndex) {
                                  final item = recordsForDay[recordIndex];
                                  final checkInText = timeFormat.format(
                                    item.checkIn,
                                  );
                                  final checkOutText = item.checkOut != null
                                      ? timeFormat.format(item.checkOut!)
                                      : 'Not Checked Out';

                                  return ListTile(
                                    leading: const Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      item.email ??
                                          'Unknown Email (${item.teacherProfileId})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Check-In: $checkInText  |  Check-Out: $checkOutText',
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
