import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oj_helper/models/rating.dart';

class RatingHistoryChart extends StatelessWidget {
  final List<Rating> history;
  final String platform;

  const RatingHistoryChart({
    Key? key,
    required this.history,
    required this.platform,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('暂无历史数据'));
    }

    // Prepare data points
    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.curRating.toDouble());
    }).toList();

    // Determine Y axis range
    double minY = history.map((e) => e.curRating).reduce((a, b) => a < b ? a : b).toDouble();
    double maxY = history.map((e) => e.curRating).reduce((a, b) => a > b ? a : b).toDouble();
    
    // Add some padding to Y axis
    double padding = (maxY - minY) * 0.2;
    if (padding < 100) padding = 100;
    minY = (minY - padding).clamp(0, double.infinity);
    maxY = maxY + padding;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true),
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final rating = history[spot.x.toInt()];
                  final date = DateFormat('yyyy-MM-dd').format(
                    DateTime.fromMillisecondsSinceEpoch(rating.time * 1000),
                  );
                  return LineTooltipItem(
                    '${rating.name}\nRating: ${rating.curRating}\n$date',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
