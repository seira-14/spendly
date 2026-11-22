import 'package:flutter/material.dart';
import '../core/network/token_storage.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  DashboardModel? _dashboardData;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isBalanceVisible = true;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardModel? get dashboardData => _dashboardData;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  bool get isBalanceVisible => _isBalanceVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DashboardProvider() {
    _loadBalanceVisibility();
  }

  Future<void> _loadBalanceVisibility() async {
    _isBalanceVisible = await TokenStorage.getBalanceVisibility();
    notifyListeners();
  }

  Future<void> toggleBalanceVisibility() async {
    _isBalanceVisible = !_isBalanceVisible;
    await TokenStorage.setBalanceVisibility(_isBalanceVisible);
    notifyListeners();
  }

  Future<void> setMonthYear(int month, int year) async {
    _selectedMonth = month;
    _selectedYear = year;
    await fetchDashboard();
  }

  Future<void> fetchDashboard({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _dashboardData = await _apiService.getDashboard(
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
