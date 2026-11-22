import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/app_avatar.dart';
import '../expense/add_expense_screen.dart';
import '../expense/expense_detail_modal.dart';
import 'widgets/balance_card.dart';
import 'widgets/category_card_list.dart';
import 'widgets/category_donut_chart.dart';
import 'widgets/recent_transactions_list.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<DashboardProvider>().fetchDashboard(),
      context.read<CategoryProvider>().fetchCategories(),
    ]);
  }

  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddExpenseScreen(),
    ).then((added) {
      if (added == true) {
        _refresh();
      }
    });
  }

  void _openExpenseDetail(ExpenseModel expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExpenseDetailModal(expense: expense),
    ).then((changed) {
      if (changed == true) {
        _refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final data = dashboard.dashboardData;
    final userName = auth.user?.name ?? data?.user.name ?? 'Teman';
    final userAvatar = auth.user?.avatar ?? data?.user.avatar;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header (Avatar, Greeting, Notification)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Profile Avatar Button
                    GestureDetector(
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(3); // Navigate to profile
                        }
                      },
                      child: AppAvatar(
                        avatarUrl: userAvatar,
                        userName: userName,
                        size: 46,
                        isAnimated: true,
                        showGlow: true,
                        showBorder: true,
                        borderColor: Colors.white,
                        borderWidth: 2,
                      ),
                    ),

                    // Center Greeting
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, $userName 💗',
                              style: GoogleFonts.outfit(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kelola pengeluaranmu hari ini',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right Notification Button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 22),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Semua notifikasi pengeluaranmu sudah terbaru!', style: GoogleFonts.outfit()),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 10,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Total Balance Piggy Card
                BalanceCard(
                  totalAmount: data?.totalExpense ?? 0.0,
                  currentMonth: dashboard.selectedMonth,
                  currentYear: dashboard.selectedYear,
                  onMonthChanged: (m, y) {
                    dashboard.setMonthYear(m, y);
                  },
                ),
                const SizedBox(height: 18),

                // 3. Category Horizontal Cards
                CategoryCardList(
                  categories: data?.categoriesSummary ?? [],
                  onCategoryTap: (catId) {
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(1); // Go to history
                    }
                  },
                ),
                const SizedBox(height: 18),

                // 4. Ringkasan Kategori Donut Chart
                CategoryDonutChart(
                  categories: data?.categoriesSummary ?? [],
                  totalAmount: data?.totalExpense ?? 0.0,
                  currentMonth: dashboard.selectedMonth,
                  currentYear: dashboard.selectedYear,
                  onPeriodTap: () {
                    // Trigger month picker
                  },
                ),
                const SizedBox(height: 18),

                // 5. Recent Transactions
                RecentTransactionsList(
                  transactions: data?.recentTransactions ?? [],
                  onViewAllTap: () {
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(1); // Switch to History Tab
                    }
                  },
                  onTransactionTap: (expense) {
                    _openExpenseDetail(expense);
                  },
                ),
                const SizedBox(height: 80), // Padding for floating button & bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }
}
