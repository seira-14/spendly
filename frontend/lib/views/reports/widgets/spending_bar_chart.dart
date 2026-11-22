import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/report_model.dart';

class SpendingBarChart extends StatelessWidget {
  final List<MonthlyTrendItem> monthlyTrend;
  final int selectedMonth;

  const SpendingBarChart({
    super.key,
    required this.monthlyTrend,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxAmount = monthlyTrend.fold<double>(
      0.0,
      (max, item) => item.amount > max ? item.amount : max,
    );

    final maxY = maxAmount > 0 ? maxAmount * 1.25 : 1000000.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardPinkBorder.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tren Pengeluaran Bulanan',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardPinkLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tahun Berjalan',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bar Chart Container
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                    tooltipRoundedRadius: 10,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = monthlyTrend[groupIndex];
                      return BarTooltipItem(
                        '${item.name}\n${CurrencyFormatter.format(item.amount)}',
                        GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          CurrencyFormatter.formatCompact(value),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthlyTrend.length) return const SizedBox.shrink();
                        final item = monthlyTrend[index];
                        final isCurrent = item.month == selectedMonth;

                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            item.name,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(monthlyTrend.length, (index) {
                  final item = monthlyTrend[index];
                  final isCurrent = item.month == selectedMonth;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.amount,
                        width: 14,
                        gradient: isCurrent
                            ? const LinearGradient(
                                colors: [Color(0xFFFF8FA3), Color(0xFFFF5C8A)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.35),
                                  AppColors.primary.withOpacity(0.2),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
