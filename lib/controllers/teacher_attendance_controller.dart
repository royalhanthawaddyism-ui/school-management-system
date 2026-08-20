import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:hism_management_system/models/teacher_attendance.dart';
import 'package:hism_management_system/services/teacher_attendance_service.dart';

class TeacherAttendanceController extends ChangeNotifier {
  final TeacherAttendanceService _service = TeacherAttendanceService();

  final double schoolLat = 17.3095073;
  final double schoolLng = 96.4650853;
  final double maxAllowedDistanceMeters = 100.0;

  bool isWithinRange = false;
  bool isCheckedIn = false;
  bool isCheckedOut = false;
  bool isLoading = false;
  bool isFetchingLocation = false;
  bool isSubmitting = false;

  double? currentDistanceMeters;
  TeacherAttendanceModel? currentRecord;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<DateTime> daysInMonth = [];
  Map<String, List<TeacherAttendanceModel>> attendanceMap = {};
  String? errorMessage;
  Timer? _timer;

  List<DateTime> _getDaysInMonth(int year, int month) {
    final now = DateTime.now();
    int maxDay;

    if (year == now.year && month == now.month) {
      maxDay = now.day;
    } else {
      maxDay = DateTime(year, month + 1, 0).day;
    }

    final days = List.generate(
      maxDay,
      (index) => DateTime(year, month, index + 1),
    );

    return days.reversed.toList();
  }

  void setMonth(int month) {
    selectedMonth = month;
    notifyListeners();
  }

  void setYear(int year) {
    selectedYear = year;
    notifyListeners();
  }

  Future<void> fetchMonthlyAttendance() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final fetchedRecords = await _service.fetchAttendanceForMonth(
        selectedYear,
        selectedMonth,
      );
      final groupedRecords = <String, List<TeacherAttendanceModel>>{};

      for (final record in fetchedRecords) {
        final dateKey = DateFormat('yyyy-MM-dd').format(record.attendanceDate);
        groupedRecords.putIfAbsent(dateKey, () => []).add(record);
      }

      daysInMonth = _getDaysInMonth(selectedYear, selectedMonth);
      attendanceMap = groupedRecords;
    } catch (e) {
      errorMessage = 'Error fetching attendance: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void init(String teacherProfileId) {
    refreshState(teacherProfileId);
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => refreshState(teacherProfileId),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> refreshState(String teacherProfileId) async {
    isLoading = true;
    notifyListeners();
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T').first;

    try {
      final record = await _service.fetchTodayAttendance(
        teacherProfileId,
        todayStr,
      );
      currentRecord = record;

      isCheckedIn = record != null;
      isCheckedOut = record?.checkOut != null;

      isWithinRange = await _checkGeofence();
    } catch (e) {
      debugPrint('Error refreshing state: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _checkGeofence() async {
    if (isFetchingLocation) return isWithinRange;
    isFetchingLocation = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }
      if (permission == LocationPermission.deniedForever) return false;

      final androidSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        forceLocationManager: true,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: androidSettings,
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        schoolLat,
        schoolLng,
      );

      currentDistanceMeters = distance;
      return distance <= maxAllowedDistanceMeters;
    } catch (e) {
      debugPrint('Error obtaining location: $e');
      return false;
    } finally {
      isFetchingLocation = false;
    }
  }

  Future<bool> handleCheckIn(String teacherProfileId) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final newRecord = TeacherAttendanceModel(
        teacherProfileId: teacherProfileId,
        attendanceDate: now,
        checkIn: now,
      );

      currentRecord = await _service.insertCheckIn(newRecord);
      isCheckedIn = true;
      return true;
    } catch (e) {
      debugPrint('Error checking in: $e');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> handleCheckOut() async {
    if (currentRecord == null) return false;

    isSubmitting = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      await _service.updateCheckOut(currentRecord!);

      currentRecord = currentRecord!.copyWith(checkOut: now);
      isCheckedOut = true;
      return true;
    } catch (e) {
      debugPrint('Error checking out: $e');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String getDistanceText() {
    if (currentDistanceMeters == null) return "Fetching distance...";
    if (currentDistanceMeters! >= 1000) {
      double km = currentDistanceMeters! / 1000;
      return "You are ${km.toStringAsFixed(2)} km away from school.";
    } else {
      return "You are ${currentDistanceMeters!.toStringAsFixed(0)} meters away from school.";
    }
  }
}
