import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherAttendanceSelfView extends StatefulWidget {
  const TeacherAttendanceSelfView({super.key});

  @override
  State<TeacherAttendanceSelfView> createState() =>
      _TeacherAttendanceSelfViewState();
}

class _TeacherAttendanceSelfViewState extends State<TeacherAttendanceSelfView> {
  // Set school coordinates and distance constraint
  final double schoolLat = 17.309569;
  final double schoolLng = 96.465086;
  final double maxAllowedDistanceMeters = 100.0;

  bool isWithinRange = false;
  bool isCheckedIn = false;
  bool isCheckedOut = false;
  bool isLoading = true;
  DateTime? checkInTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refreshState();
    // Periodically update location and state (every 10 seconds)
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshState(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshState() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // 1. Reset state after 00:00 AM (Midnight)
    final lastResetDateStr = prefs.getString('last_reset_date');
    final currentDateStr = "${now.year}-${now.month}-${now.day}";

    if (lastResetDateStr != currentDateStr) {
      await prefs.setBool('is_checked_in', false);
      await prefs.setBool('is_checked_out', false);
      await prefs.remove('check_in_timestamp');
      await prefs.setString('last_reset_date', currentDateStr);
    }

    // 2. Fetch stored attendance states
    final savedCheckedIn = prefs.getBool('is_checked_in') ?? false;
    final savedCheckedOut = prefs.getBool('is_checked_out') ?? false;
    final savedCheckInMs = prefs.getInt('check_in_timestamp');

    DateTime? savedTime;
    if (savedCheckInMs != null) {
      savedTime = DateTime.fromMillisecondsSinceEpoch(savedCheckInMs);
    }

    // 3. Verify Geofence with safety error handling
    bool inRange = false;
    try {
      inRange = await _checkGeofence();
    } catch (e) {
      if (kDebugMode) debugPrint("❌ Geofence Refresh Exception: $e");
      inRange = false;
    }

    if (mounted) {
      setState(() {
        isCheckedIn = savedCheckedIn;
        isCheckedOut = savedCheckedOut;
        checkInTime = savedTime;
        isWithinRange = inRange;
        isLoading = false; // Always disable loading screen when done
      });
    }
  }

  Future<bool> _checkGeofence() async {
    // Check if location services (GPS) are enabled on the device
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode)
        debugPrint(
          "❌ Geofence Error: Location services are DISABLED on device.",
        );
      return false;
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode)
          debugPrint("❌ Geofence Error: Location permission DENIED by user.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode)
        debugPrint("❌ Geofence Error: Location permission DENIED PERMANENTLY.");
      return false;
    }

    // Fetch position with timeout safety
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        schoolLat,
        schoolLng,
      );

      if (kDebugMode) {
        debugPrint("----------------------------------------");
        debugPrint(
          "📍 User Location: ${position.latitude}, ${position.longitude}",
        );
        debugPrint("🏫 School Location: $schoolLat, $schoolLng");
        debugPrint(
          "📏 Distance to School: ${distance.toStringAsFixed(2)} meters",
        );
        debugPrint("----------------------------------------");
      }

      return distance <= maxAllowedDistanceMeters;
    } catch (e) {
      if (kDebugMode) debugPrint("❌ Geofence Error during position fetch: $e");
      return false;
    }
  }

  Future<void> _handleCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    await prefs.setBool('is_checked_in', true);
    await prefs.setInt('check_in_timestamp', now.millisecondsSinceEpoch);

    setState(() {
      isCheckedIn = true;
      checkInTime = now;
    });
  }

  Future<void> _handleCheckOut() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_checked_out', true);

    setState(() {
      isCheckedOut = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Evaluate if 45 minutes have elapsed since Check In
    bool canCheckOut = false;
    int remainingMinutes = 45;

    if (checkInTime != null) {
      final elapsedMinutes = now.difference(checkInTime!).inMinutes;
      canCheckOut = elapsedMinutes >= 45;
      remainingMinutes = (45 - elapsedMinutes).clamp(0, 45);
    }

    // Determine visibility rules
    bool showCheckInButton = isWithinRange && !isCheckedIn;
    bool showCheckOutButton =
        isWithinRange && isCheckedIn && canCheckOut && !isCheckedOut;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Attendance'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Location Status Card
                  Card(
                    color: isWithinRange
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            isWithinRange
                                ? Icons.location_on
                                : Icons.location_off,
                            color: isWithinRange ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isWithinRange
                                  ? "Within School Range (≤ 100m)"
                                  : "Outside School Range (> 100m)",
                              style: TextStyle(
                                color: isWithinRange
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

                  // Out of Range Message
                  if (!isWithinRange)
                    const Text(
                      "Buttons are hidden because you are not within 100 meters of the school.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),

                  // Check In Button
                  if (showCheckInButton)
                    ElevatedButton.icon(
                      onPressed: _handleCheckIn,
                      icon: const Icon(Icons.login),
                      label: const Text('Check In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                  // Waiting Period Message (Checked In, but under 45 minutes)
                  if (isWithinRange &&
                      isCheckedIn &&
                      !canCheckOut &&
                      !isCheckedOut) ...[
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
                      "Check Out available in: $remainingMinutes minute(s)",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],

                  // Check Out Button
                  if (showCheckOutButton)
                    ElevatedButton.icon(
                      onPressed: _handleCheckOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Check Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                  // Completed Day Message
                  if (isCheckedOut)
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
