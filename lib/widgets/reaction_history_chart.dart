import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/reaction_result.dart';
import '../utils/constants.dart';

class ReactionHistoryChart extends StatelessWidget {
  final List<ReactionResult> results;
  final int? goalMs;

  const ReactionHistoryChart({super.key, required this.results, this.goalMs});

  @override
  Widget build(BuildContext context) {
    if (results.length < 2) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Complete at least 2 tests\nto see your trend chart',
            style: TextStyle(color: Colors.white38, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final displayResults = results.length > 50
        ? results.sublist(results.length - 50)
        : results;

    final spots = displayResults.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.reactionTimeMs.toDouble());
    }).toList();

    final dataMax = displayResults
        .map((r) => r.reactionTimeMs)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final dataMin = displayResults
        .map((r) => r.reactionTimeMs)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();

    // Ensure the goal line and human avg line are within the visible range
    final referenceLines = [
      AppConstants.humanAverageMs.toDouble(),
      if (goalMs != null) goalMs!.toDouble(),
    ];
    final effectiveMax = ([dataMax, ...referenceLines].reduce((a, b) => a > b ? a : b));
    final effectiveMin = ([dataMin, ...referenceLines].reduce((a, b) => a < b ? a : b));

    final maxY = effectiveMax + 50;
    final minY = (effectiveMin - 50).clamp(0.0, double.infinity);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 100,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: 100,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}',
                  style:
                      const TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: AppConstants.humanAverageMs.toDouble(),
                color: Colors.amber.withValues(alpha: 0.5),
                strokeWidth: 1,
                dashArray: [8, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: TextStyle(
                    color: Colors.amber.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                  labelResolver: (_) => 'Human Avg',
                ),
              ),
              if (goalMs != null)
                HorizontalLine(
                  y: goalMs!.toDouble(),
                  color: Colors.greenAccent.withValues(alpha: 0.6),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topLeft,
                    style: TextStyle(
                      color: Colors.greenAccent.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                    labelResolver: (_) => 'Your Goal',
                  ),
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.2,
              color: AppColors.ready,
              barWidth: 2,
              dotData: FlDotData(
                show: displayResults.length <= 20,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.ready,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.ready.withValues(alpha: 0.15),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()}ms',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
