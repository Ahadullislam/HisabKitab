import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/dashboard_models.dart';

class ExpensePieChart extends StatefulWidget {
  final List<CatBreakdown> data;
  const ExpensePieChart({super.key, required this.data});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text('No expenses this month',
              style: TextStyle(color: AppColors.textHint)),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (response?.touchedSection != null &&
                          event is! FlTapUpEvent) {
                        _touched = response!
                            .touchedSection!.touchedSectionIndex;
                      } else {
                        _touched = -1;
                      }
                    });
                  },
                ),
                centerSpaceRadius: 45,
                sectionsSpace:     2,
                sections: List.generate(widget.data.length, (i) {
                  final d         = widget.data[i];
                  final isTouched = _touched == i;
                  return PieChartSectionData(
                    value:      d.amount,
                    color:      Color(d.colorValue)
                        .withOpacity(isTouched ? 1.0 : 0.8),
                    radius:     isTouched ? 60 : 50,
                    showTitle:  isTouched,
                    title: '${(d.percent * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Legend
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.data.length, (i) {
              final d         = widget.data[i];
              final isTouched = _touched == i;
              return GestureDetector(
                onTap: () =>
                    setState(() => _touched = _touched == i ? -1 : i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTouched
                        ? Color(d.colorValue).withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color:  Color(d.colorValue),
                          shape:  BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.icon + ' ' + d.name,
                              style: TextStyle(
                                fontSize:   11,
                                fontWeight: isTouched
                                    ? FontWeight.w700 : FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              CurrencyFormatter.formatCompact(d.amount),
                              style: TextStyle(
                                fontSize:   10,
                                color:      Color(d.colorValue),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}