import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/controllers/teacher_attendance_controller.dart';

class TeacherAttendanceSelfView extends StatefulWidget {
  const TeacherAttendanceSelfView({super.key});

  @override
  State<TeacherAttendanceSelfView> createState() =>
      _TeacherAttendanceSelfViewState();
}

class _TeacherAttendanceSelfViewState extends State<TeacherAttendanceSelfView> {
  late final TeacherAttendanceController _controller;
  late final String _teacherProfileId;
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    _controller = TeacherAttendanceController();
    _controller.addListener(_onControllerUpdate);

    _teacherProfileId = Supabase.instance.client.auth.currentUser?.id ?? '';
    _controller.init(_teacherProfileId);

    _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _controller.isCheckedIn && !_controller.isCheckedOut) {
        setState(() {});
      }
    });
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    bool canCheckOut = false;
    int remainingMinutes = 45;
    int remainingSeconds = 0;

    if (_controller.currentRecord?.checkIn != null) {
      // FIX 1: Convert Supabase UTC timestamp to local time automatically.
      // Remove manual subtract(Duration(minutes: 390)).
      final checkInTime = _controller.currentRecord!.checkIn.toLocal();

      final elapsedDuration = now.difference(checkInTime);
      const totalRequiredDuration = Duration(minutes: 45);

      if (elapsedDuration >= totalRequiredDuration) {
        canCheckOut = true;
        remainingMinutes = 0;
        remainingSeconds = 0;
      } else {
        canCheckOut = false;
        final remainingDuration = totalRequiredDuration - elapsedDuration;

        // Ensure countdown doesn't show negative values
        if (remainingDuration.isNegative) {
          canCheckOut = true;
          remainingMinutes = 0;
          remainingSeconds = 0;
        } else {
          remainingMinutes = remainingDuration.inMinutes;
          remainingSeconds = remainingDuration.inSeconds % 60;
        }
      }
    }

    bool showCheckInButton =
        _controller.isWithinRange && !_controller.isCheckedIn;

    bool showCheckOutButton =
        _controller.isWithinRange &&
        _controller.isCheckedIn &&
        canCheckOut &&
        !_controller.isCheckedOut;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Attendance'),
        centerTitle: true,
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: _controller.isWithinRange
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            _controller.isWithinRange
                                ? Icons.location_on
                                : Icons.location_off,
                            color: _controller.isWithinRange
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _controller.isWithinRange
                                  ? "Within School Range (≤ 100m)"
                                  : "Outside School Range (> 100m)",
                              style: TextStyle(
                                color: _controller.isWithinRange
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_controller.isWithinRange)
                    Text(
                      _controller.getDistanceText(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (showCheckInButton)
                    ElevatedButton.icon(
                      onPressed: _controller.isSubmitting
                          ? null
                          : () async {
                              await _controller.handleCheckIn(
                                _teacherProfileId,
                              );
                            },
                      icon: const Icon(Icons.login),
                      label: _controller.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Check In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  if (_controller.isWithinRange &&
                      _controller.isCheckedIn &&
                      !canCheckOut &&
                      !_controller.isCheckedOut) ...[
                    const Text(
                      "Checked In Successfully",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Check Out available in: ${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (showCheckOutButton)
                    ElevatedButton.icon(
                      onPressed: _controller.isSubmitting
                          ? null
                          : () async {
                              await _controller.handleCheckOut();
                            },
                      icon: const Icon(Icons.logout),
                      label: _controller.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Check Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  if (_controller.isCheckedOut)
                    const Text(
                      "Attendance Completed for Today!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
