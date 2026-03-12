import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/dashboard_models.dart';

class MonthlyBarChart extends StatefulWidget {
  final List<MonthData> data;
  const MonthlyBarChart({super.key, required this.data});

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          maxY: _maxY(),
          barTouchData: BarTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (response?.spot != null &&
                    event is! FlTapUpEvent &&
                    event is! FlPanEndEvent) {
                  _touched = response!.spot!.touchedBarGroupIndex;
                } else {
                  _touched = -1;
                }
              });
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
              isDark ? AppColors.darkCard : Colors.white,
              getTooltipItem: (group, _, rod, rodIndex) {
                final d      = widget.data[group.x];
                final label  = rodIndex == 0 ? 'Income' : 'Expense';
                final amount = rodIndex == 0 ? d.income : d.expense;
                final color  = rodIndex == 0
                    ? AppColors.income : AppColors.expense;
                return BarTooltipItem(
                  '$label\n৳${amount.toStringAsFixed(0)}',
                  TextStyle(
                    color:      color,
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= widget.data.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      widget.data[i].label,
                      style: TextStyle(
                        fontSize: 10,
                        color: _touched == i
                            ? AppColors.primary
                            : AppColors.textHint,
                        fontWeight: _touched == i
                            ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            drawHorizontalLine: true,
            drawVerticalLine:   false,
            getDrawingHorizontalLine: (_) => FlLine(
              color:       AppColors.divider.withOpacity(0.5),
              strokeWidth: 1,
              dashArray:   [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(widget.data.length, (i) {
            final d         = widget.data[i];
            final isTouched = _touched == i;
            return BarChartGroupData(
              x:       i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY:          d.income,
                  color:        AppColors.income
                      .withOpacity(isTouched ? 1.0 : 0.75),
                  width:        isTouched ? 12 : 10,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY:          d.expense,
                  color:        AppColors.expense
                      .withOpacity(isTouched ? 1.0 : 0.75),
                  width:        isTouched ? 12 : 10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  double _maxY() {
    if (widget.data.isEmpty) return 1000;
    final max = widget.data
        .expand((d) => [d.income, d.expense])
        .fold(0.0, (m, v) => v > m ? v : m);
    return max == 0 ? 1000 : max * 1.2;
  }
}