import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';

class AttendanceRing extends StatelessWidget {
  final double percentage;
  final double minPercentage;
  final double size;
  final double strokeWidth;

  const AttendanceRing({
    super.key,
    required this.percentage,
    required this.minPercentage,
    this.size = 120,
    this.strokeWidth = 12,
  });

  Color get _color {
    if (percentage >= minPercentage) {
      return percentage >= 90 ? AppTheme.success : AppTheme.secondary;
    }
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: size / 2 - strokeWidth,
              sections: [
                PieChartSectionData(
                  value: percentage.clamp(0, 100),
                  color: _color,
                  radius: strokeWidth,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: (100 - percentage).clamp(0, 100),
                  color: AppTheme.cardLight,
                  radius: strokeWidth,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
