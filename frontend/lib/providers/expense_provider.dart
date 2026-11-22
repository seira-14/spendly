import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/api_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ExpenseModel> _expenses = [];
  int? _filterMonth;
  int? _filterYear;
  int? _filterCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpenseModel> get expenses => _expenses;
  int? get filterMonth => _filterMonth;
  int? get filterYear => _filterYear;
  int? get filterCategoryId => _filterCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalFilteredAmount {
    return _expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> fetchExpenses({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _expenses = await _apiService.getExpenses(
        month: _filterMonth,
        year: _filterYear,
        categoryId: _filterCategoryId,
        search: _searchQuery,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createExpense({
    required int categoryId,
    required String title,
    required double amount,
    required String date,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newExpense = await _apiService.createExpense(
        categoryId: categoryId,
        title: title,
        amount: amount,
        date: date,
        notes: notes,
      );

      _expenses.insert(0, newExpense);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense({
    required int id,
    int? categoryId,
    String? title,
    double? amount,
    String? date,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _apiService.updateExpense(
        id: id,
        categoryId: categoryId,
        title: title,
        amount: amount,
        date: date,
        notes: notes,
      );

      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _apiService.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setFilterMonthYear(int? month, int? year) {
    _filterMonth = month;
    _filterYear = year;
    fetchExpenses();
  }

  void setFilterCategory(int? categoryId) {
    if (_filterCategoryId == categoryId) {
      _filterCategoryId = null; // Toggle off if clicked again
    } else {
      _filterCategoryId = categoryId;
    }
    fetchExpenses();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchExpenses();
  }

  void clearFilters() {
    _filterMonth = null;
    _filterYear = null;
    _filterCategoryId = null;
    _searchQuery = '';
    fetchExpenses();
  }
}
