import 'dart:async';
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
  final double schoolLat = 17.3095073;
  final double schoolLng = 96.4650853;
  final double maxAllowedDistanceMeters = 100.0;

  bool isWithinRange = false;
  bool isCheckedIn = false;
  bool isCheckedOut = false;
  bool isLoading = true;
  bool isFetchingLocation = false;
  double? currentDistanceMeters;
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
      inRange = false;
    }

    if (mounted) {
      setState(() {
        isCheckedIn = savedCheckedIn;
        isCheckedOut = savedCheckedOut;
        checkInTime = savedTime;
        isWithinRange = inRange;
        isLoading = false;
      });
    }
  }

  Future<bool> _checkGeofence() async {
    if (isFetchingLocation) return isWithinRange;
    isFetchingLocation = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Android သီးသန့် Hardware GPS Direct Settings
      final androidSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        forceLocationManager:
            true, // Device GPS Hardware ကို တိုက်ရိုက် သုံးခိုင်းခြင်း
      );

      // Current Position ရယူခြင်း
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: androidSettings,
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        schoolLat,
        schoolLng,
      );

      print('Current Lat/Lng: ${position.latitude}, ${position.longitude}');
      print('Accuracy Margin: ${position.accuracy} meters');

      if (mounted) {
        setState(() {
          currentDistanceMeters = distance;
        });
      }

      return distance <= maxAllowedDistanceMeters;
    } catch (e) {
      debugPrint('Error obtaining location: $e');
      return false;
    } finally {
      isFetchingLocation = false;
    }
  }

  String _getDistanceText() {
    if (currentDistanceMeters == null) {
      return "Fetching distance...";
    }
    if (currentDistanceMeters! >= 1000) {
      double km = currentDistanceMeters! / 1000;
      return "You are ${km.toStringAsFixed(2)} km away from school.";
    } else {
      return "You are ${currentDistanceMeters!.toStringAsFixed(0)} meters away from school.";
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

    bool canCheckOut = false;
    int remainingMinutes = 45;

    if (checkInTime != null) {
      final elapsedMinutes = now.difference(checkInTime!).inMinutes;
      canCheckOut = elapsedMinutes >= 45;
      remainingMinutes = (45 - elapsedMinutes).clamp(0, 45);
    }

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
                  if (!isWithinRange)
                    Text(
                      _getDistanceText(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
