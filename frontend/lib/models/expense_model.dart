import 'category_model.dart';

class ExpenseModel {
  final int id;
  final int userId;
  final int categoryId;
  final String title;
  final double amount;
  final String date;
  final String? notes;
  final String? createdAt;
  final CategoryModel? category;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.amount,
    required this.date,
    this.notes,
    this.createdAt,
    this.category,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id'].toString()) ?? 0,
      title: json['title'] ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount'].toString()) ?? 0.0,
      date: json['date'] ?? '',
      notes: json['notes'],
      createdAt: json['created_at'],
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'amount': amount,
      'date': date,
      'notes': notes,
    };
  }
}
