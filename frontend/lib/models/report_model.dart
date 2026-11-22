import 'dashboard_model.dart';
import 'expense_model.dart';

class DailyExpenseItem {
  final int day;
  final String date;
  final double amount;

  DailyExpenseItem({
    required this.day,
    required this.date,
    required this.amount,
  });

  factory DailyExpenseItem.fromJson(Map<String, dynamic> json) {
    return DailyExpenseItem(
      day: json['day'] is int ? json['day'] : int.tryParse(json['day'].toString()) ?? 1,
      date: json['date'] ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount'].toString()) ?? 0.0,
    );
  }
}

class MonthlyTrendItem {
  final int month;
  final String name;
  final double amount;

  MonthlyTrendItem({
    required this.month,
    required this.name,
    required this.amount,
  });

  factory MonthlyTrendItem.fromJson(Map<String, dynamic> json) {
    return MonthlyTrendItem(
      month: json['month'] is int ? json['month'] : int.tryParse(json['month'].toString()) ?? 1,
      name: json['name'] ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount'].toString()) ?? 0.0,
    );
  }
}

class ReportModel {
  final int month;
  final int year;
  final double totalExpense;
  final double previousMonthExpense;
  final double percentageChange;
  final double averageDailyExpense;
  final ExpenseModel? highestExpense;
  final List<CategorySummaryItem> categoriesBreakdown;
  final List<DailyExpenseItem> dailyExpenses;
  final List<MonthlyTrendItem> monthlyTrend;

  ReportModel({
    required this.month,
    required this.year,
    required this.totalExpense,
    required this.previousMonthExpense,
    required this.percentageChange,
    required this.averageDailyExpense,
    this.highestExpense,
    required this.categoriesBreakdown,
    required this.dailyExpenses,
    required this.monthlyTrend,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final filterJson = data['filter'] ?? {};
    final catList = (data['categories_breakdown'] as List<dynamic>?) ?? [];
    final dailyList = (data['daily_expenses'] as List<dynamic>?) ?? [];
    final trendList = (data['monthly_trend'] as List<dynamic>?) ?? [];

    return ReportModel(
      month: filterJson['month'] is int ? filterJson['month'] : int.tryParse(filterJson['month'].toString()) ?? DateTime.now().month,
      year: filterJson['year'] is int ? filterJson['year'] : int.tryParse(filterJson['year'].toString()) ?? DateTime.now().year,
      totalExpense: (data['total_expense'] is num) ? (data['total_expense'] as num).toDouble() : double.tryParse(data['total_expense'].toString()) ?? 0.0,
      previousMonthExpense: (data['previous_month_expense'] is num) ? (data['previous_month_expense'] as num).toDouble() : double.tryParse(data['previous_month_expense'].toString()) ?? 0.0,
      percentageChange: (data['percentage_change'] is num) ? (data['percentage_change'] as num).toDouble() : double.tryParse(data['percentage_change'].toString()) ?? 0.0,
      averageDailyExpense: (data['average_daily_expense'] is num) ? (data['average_daily_expense'] as num).toDouble() : double.tryParse(data['average_daily_expense'].toString()) ?? 0.0,
      highestExpense: data['highest_expense'] != null ? ExpenseModel.fromJson(data['highest_expense']) : null,
      categoriesBreakdown: catList.map((e) => CategorySummaryItem.fromJson(e)).toList(),
      dailyExpenses: dailyList.map((e) => DailyExpenseItem.fromJson(e)).toList(),
      monthlyTrend: trendList.map((e) => MonthlyTrendItem.fromJson(e)).toList(),
    );
  }
}
