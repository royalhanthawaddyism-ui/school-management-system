import 'package:flutter/material.dart';
import 'package:hism_management_system/setup/setupModels/year.dart';
import 'package:hism_management_system/setup/setupServices/year_service.dart';

class YearController extends ChangeNotifier {
  final YearService _service = YearService();

  List<Year> _years = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Year> get years => _years;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // year_controller.dart ထဲမှ loadYears, addYear, editYear အပိုင်းများကို ဤသို့ပြင်ပါ-

  Future<void> loadYears() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _years = await _service.fetchYears();
      _years.sort((a, b) => a.id.compareTo(b.id));
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addYear(String name) async {
    try {
      final newYear = await _service.createYear(name);
      _years.add(newYear);
      _years.sort((a, b) => a.id.compareTo(b.id));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> editYear(String id, String newName) async {
    try {
      await _service.updateYear(id, newName);
      final index = _years.indexWhere((y) => y.id == id);
      if (index != -1) {
        _years[index] = Year(
          id: _years[index].id,
          name: newName,
          deleted: _years[index].deleted,
          createdAt: _years[index].createdAt,
          updatedAt: DateTime.now(),
        );
        _years.sort((a, b) => a.id.compareTo(b.id));
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteYear(String id) async {
    try {
      await _service.softDeleteYear(id);
      _years.removeWhere((y) => y.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
