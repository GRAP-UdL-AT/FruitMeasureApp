import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fruit_measure_app/domains/charts/models/plot_chart_series.dart';
import 'package:fruit_measure_app/domains/plots/models/group_of_plots_values.dart';
import 'package:fruit_measure_app/utils/get_color_by_index.dart';
import 'package:intl/intl.dart';

class GrowthLineChartComponent extends StatelessWidget {
  const GrowthLineChartComponent({super.key, required this.series});

  final PlotChartSeries series;

  @override
  Widget build(BuildContext context) {
    final (
      double maxCount,
      List<LineChartBarData> chartLines,
    ) = createLineChartGroups(
      measurements: series.plots,
      dates: series.getLatestMeasurementDates(),
    );

    return createLineChart(
      chartLines: chartLines,
      maxCount: maxCount,
      dates: series.getLatestMeasurementDates(),
    );
  }

  (double, List<LineChartBarData>) createLineChartGroups({
    required List<GroupOfPlotsValues> measurements,
    required List<DateTime> dates,
  }) {
    final List<LineChartBarData> chartLines = [];
    double max = 0;

    final DateTime? firstDate = dates.isNotEmpty ? dates.first : null;

    for (int m = 0; m < measurements.length; m++) {
      final calibers = measurements[m].getCalibers();
      final calibersEntries =
          calibers.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      final List<FlSpot> spots = [];

      for (final entry in calibersEntries) {
        final value = entry.value;
        final date = entry.key;

        if (value > max) max = value;

        double xPosition = 0;
        if (firstDate != null) {
          xPosition = date.difference(firstDate).inDays.toDouble();
        }

        spots.add(FlSpot(xPosition, value));
      }

      chartLines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 2,
          color: getColorByIndex(m),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: getColorByIndex(m),
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      );

      // -- (DEMO) PREDICTIONS - COMENTADO: No mostrar predicciones futuras
      // const int kPredictionPoints = 3;
      // final List<FlSpot> predictionSpots = [];
      // if (calibersValues.length >= 2) {
      //   final int lastIndex = calibersValues.length - 1;
      //   final double lastX = lastIndex.toDouble();
      //   final double lastY = calibersValues[lastIndex];
      //   final double prevY = calibersValues[lastIndex - 1];
      //   final double deltaY = lastY - prevY;
      //   // GENERATE DEMO PREDICTION SPOTS
      //   for (int i = 1; i <= kPredictionPoints; i++) {
      //     final double nextX = lastX + i;
      //     final double nextY = lastY + deltaY * i;
      //     predictionSpots.add(FlSpot(nextX, nextY));
      //     if (nextY > max) max = nextY.toInt();
      //   }

      //   chartLines.add(
      //     LineChartBarData(
      //       spots: [FlSpot(lastX, lastY), ...predictionSpots],
      //       isCurved: true,
      //       barWidth: 2,
      //       color: getColorByIndex(m),
      //       dotData: const FlDotData(show: true),
      //       dashArray: const [6, 4],
      //     ),
      //   );
      // }
    }

    return (max, chartLines);
  }

  LineChart createLineChart({
    required List<LineChartBarData> chartLines,
    required double maxCount,
    required List<DateTime> dates,
  }) {
    if (chartLines.isEmpty || dates.isEmpty) {
      return LineChart(
        LineChartData(
          lineBarsData: [],
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      );
    }

    final double maxY = maxCount * 1.10;

    final DateTime firstDate = dates.first;
    final DateTime lastDate = dates.last;
    final double maxX = lastDate.difference(firstDate).inDays.toDouble();

    final double adjustedMaxX = maxX > 0 ? maxX * 1.05 : 1;
    final double adjustedMinX = maxX > 0 ? -maxX * 0.05 : 0;

    final List<int> dataPointDays =
        dates.map((date) => date.difference(firstDate).inDays).toSet().toList()
          ..sort();

    final Set<int> labelsToShow = <int>{};

    final double minSpacingRelative = maxX * 0.05;

    if (dataPointDays.isNotEmpty) {
      labelsToShow.add(dataPointDays.first);

      if (dataPointDays.length > 1) {
        labelsToShow.add(dataPointDays.last);
      }

      for (int i = 1; i < dataPointDays.length - 1; i++) {
        final currentDay = dataPointDays[i];
        bool canShow = true;

        for (final shownDay in labelsToShow) {
          if ((currentDay - shownDay).abs() < minSpacingRelative) {
            canShow = false;
            break;
          }
        }

        if (canShow) {
          labelsToShow.add(currentDay);
        }
      }
    }

    return LineChart(
      LineChartData(
        lineBarsData: chartLines,
        minY: 0,
        maxY: maxY,
        minX: adjustedMinX,
        maxX: adjustedMaxX,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipMargin: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final dayOffset = spot.x.round();
                final date = firstDate.add(Duration(days: dayOffset));
                return LineTooltipItem(
                  '${DateFormat('dd/MM/yyyy').format(date)}\n${spot.y.toStringAsFixed(2)} mm',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > maxX) {
                  return const SizedBox.shrink();
                }

                final int dayOffset = value.round();

                if (labelsToShow.contains(dayOffset)) {
                  final DateTime dateAtPosition = firstDate.add(
                    Duration(days: dayOffset),
                  );

                  return SideTitleWidget(
                    meta: meta,
                    child: Transform.rotate(
                      angle: -1.5708,
                      child: Text(
                        DateFormat('dd/MM').format(dateAtPosition),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, _) {
                return Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
