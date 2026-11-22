import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';

class CategoryModel {
  final int id;
  final String name;
  final String? icon;
  final String? color;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  /// Resolve IconData for this category
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
        if (icon == 'wallet') return Icons.account_balance_wallet_outlined;
        if (icon == 'shopping-bag') return Icons.shopping_bag_outlined;
        if (icon == 'car') return Icons.directions_car_outlined;
        if (icon == 'coffee') return Icons.coffee_rounded;
        if (icon == 'shopping-cart') return Icons.shopping_cart_outlined;
        if (icon == 'gift') return Icons.card_giftcard_rounded;
        return Icons.category_outlined;
    }
  }

  /// Resolve Color for this category
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
