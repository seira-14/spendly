import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  ReportModel? _reportData;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;
  String? _errorMessage;

  ReportModel? get reportData => _reportData;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> setMonthYear(int month, int year) async {
    _selectedMonth = month;
    _selectedYear = year;
    await fetchReports();
  }

  Future<void> fetchReports({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _reportData = await _apiService.getReports(
        month: _selectedMonth,
        year: _selectedYear,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
