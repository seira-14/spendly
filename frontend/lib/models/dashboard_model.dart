import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'expense_model.dart';
import 'user_model.dart';

class CategorySummaryItem {
  final int categoryId;
  final String name;
  final String? icon;
  final String? color;
  final double totalAmount;
  final double percentage;

  CategorySummaryItem({
    required this.categoryId,
    required this.name,
    this.icon,
    this.color,
    required this.totalAmount,
    required this.percentage,
  });

  factory CategorySummaryItem.fromJson(Map<String, dynamic> json) {
    return CategorySummaryItem(
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      color: json['color'],
      totalAmount: (json['total_amount'] is num) ? (json['total_amount'] as num).toDouble() : double.tryParse(json['total_amount'].toString()) ?? 0.0,
      percentage: (json['percentage'] is num) ? (json['percentage'] as num).toDouble() : double.tryParse(json['percentage'].toString()) ?? 0.0,
    );
  }

  IconData get iconData {
    switch (name.toLowerCase()) {
      case 'kebutuhan':
        return Icons.account_balance_wallet_outlined;
      case 'keinginan':
        return Icons.shopping_bag_outlined;
      case 'transportasi':
        return Icons.directions_car_outlined;
      case 'lainnya':
        return Icons.more_horiz_rounded;
      case 'makanan':
        return Icons.coffee_rounded;
      case 'belanja':
        return Icons.shopping_cart_outlined;
      case 'hadiah':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  Color get colorValue {
    if (color != null && color!.startsWith('#')) {
      try {
        final hex = color!.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    switch (name.toLowerCase()) {
      case 'kebutuhan':
        return AppColors.catKebutuhan;
      case 'keinginan':
        return AppColors.catKeinginan;
      case 'transportasi':
        return AppColors.catTransportasi;
      case 'lainnya':
        return AppColors.catLainnya;
      case 'makanan':
        return AppColors.catMakanan;
      case 'belanja':
        return AppColors.catBelanja;
      case 'hadiah':
        return AppColors.catHadiah;
      default:
        return AppColors.primary;
    }
  }
}

class DashboardModel {
  final UserModel user;
  final int month;
  final int year;
  final double totalExpense;
  final List<CategorySummaryItem> categoriesSummary;
  final List<ExpenseModel> recentTransactions;

  DashboardModel({
    required this.user,
    required this.month,
    required this.year,
    required this.totalExpense,
    required this.categoriesSummary,
    required this.recentTransactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final userJson = data['user'] ?? {};
    final filterJson = data['filter'] ?? {};
    final categoriesList = (data['categories_summary'] as List<dynamic>?) ?? [];
    final transactionsList = (data['recent_transactions'] as List<dynamic>?) ?? [];

    return DashboardModel(
      user: UserModel.fromJson(userJson),
      month: filterJson['month'] is int ? filterJson['month'] : int.tryParse(filterJson['month'].toString()) ?? DateTime.now().month,
      year: filterJson['year'] is int ? filterJson['year'] : int.tryParse(filterJson['year'].toString()) ?? DateTime.now().year,
      totalExpense: (data['total_expense'] is num) ? (data['total_expense'] as num).toDouble() : double.tryParse(data['total_expense'].toString()) ?? 0.0,
      categoriesSummary: categoriesList.map((e) => CategorySummaryItem.fromJson(e)).toList(),
      recentTransactions: transactionsList.map((e) => ExpenseModel.fromJson(e)).toList(),
    );
  }
}
