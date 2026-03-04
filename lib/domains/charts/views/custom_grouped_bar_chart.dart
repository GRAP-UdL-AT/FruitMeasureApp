import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fruit_measure_app/domains/charts/models/bar_chart_series.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/get_color_by_index.dart';

List<int> calculateYTicks(int maxValue, {int? maxTicks}) {
  if (maxValue == 0) return [0];

  const candidateSteps = [1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000];

  List<int> ticks = [];
  for (final step in candidateSteps) {
    final tickCount = (maxValue / step).floor() + 1;
    if (tickCount <= 8) {
      ticks = <int>[];
      for (int i = 0; i <= tickCount; i++) {
        ticks.add(i * step);
        if (i * step >= maxValue) break;
      }
      break;
    }
  }

  if (ticks.isEmpty) {
    final step = candidateSteps.last;
    for (int i = 0; i < 8; i++) {
      ticks.add(i * step);
      if (i * step >= maxValue) break;
    }
  }

  if (maxTicks != null && ticks.length > maxTicks) {
    if (maxTicks == 1) {
      return [ticks.last];
    }
    
    final reducedTicks = <int>[];
    final usedIndices = <int>{};
    
    
    final step = (ticks.length - 1) / (maxTicks - 1);
    
    for (int i = 0; i < maxTicks; i++) {
      int index;
      if (i == 0) {
        index = 0;
      } else if (i == maxTicks - 1) {
        index = ticks.length - 1;
      } else {
        index = (i * step).round().clamp(0, ticks.length - 1);
      }
      
      if (!usedIndices.contains(index)) {
        reducedTicks.add(ticks[index]);
        usedIndices.add(index);
      }
    }
    
    if (reducedTicks.last != ticks.last) {
      reducedTicks[reducedTicks.length - 1] = ticks.last;
    }
    
    return reducedTicks;
  }

  return ticks;
}

class CustomGroupedBarChart extends StatefulWidget {
  const CustomGroupedBarChart({
    super.key,
    required this.series,
    required this.binWidth,
    this.isExportMode = false,
    this.isFullscreenHistogram = false,
    this.swapAxes = false,
    this.usePercentages = false,
    this.disableInteractions = false,
  });

  final List<BarChartSeries> series;
  final double binWidth;
  final bool isExportMode;
  final bool isFullscreenHistogram;
  final bool swapAxes;
  final bool usePercentages;
  final bool disableInteractions;

  @override
  State<CustomGroupedBarChart> createState() => _CustomGroupedBarChartState();
}

class _CustomGroupedBarChartState extends State<CustomGroupedBarChart> {
  int? _hoveredGroupIndex;
  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final chartData = _prepareChartData();
    if (chartData.isEmpty) {
      return Center(
        child: Text(
          loc.withoutData,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) {
            if (widget.disableInteractions) return;
            _handleHover(event.localPosition, constraints, chartData);
          },
          onExit: (_) {
            if (widget.disableInteractions) return;
            setState(() {
              _hoveredGroupIndex = null;
              _tapPosition = null;
            });
          },
          child: GestureDetector(
            onTapDown: (details) {
              if (widget.disableInteractions) return;
              _handleTap(details.localPosition, constraints, chartData);
            },
            onTapUp: (_) {
              if (widget.disableInteractions) return;
              Future.delayed(const Duration(milliseconds: 2000), () {
                if (mounted) {
                  setState(() {
                    _tapPosition = null;
                    _hoveredGroupIndex = null;
                  });
                }
              });
            },
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _GroupedBarChartPainter(
                    chartData: chartData,
                    series: widget.series,
                    binWidth: widget.binWidth,
                    hoveredGroupIndex: _hoveredGroupIndex,
                    isExportMode: widget.isExportMode,
                    isFullscreenHistogram: widget.isFullscreenHistogram,
                    swapAxes: widget.swapAxes,
                    usePercentages: widget.usePercentages,
                    xAxisLabel: loc.caliber,
                    yAxisLabel: widget.usePercentages ? loc.percentageOfFruits : loc.numberOfFruits,
                  ),
                ),
                if (_tapPosition != null && _hoveredGroupIndex != null)
                  _buildTooltip(
                    context,
                    chartData[_hoveredGroupIndex!],
                    _tapPosition!,
                    constraints,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_ChartGroupData> _prepareChartData() {
    if (widget.series.isEmpty) return [];

    final allValues =
        widget.series.expand((s) => s.values).where((v) => v > 0).toList();

    if (allValues.isEmpty) return [];

    final maxValue = allValues.reduce((a, b) => a > b ? a : b);

    const minBin = 0;
    final maxBin = (maxValue / widget.binWidth).ceil();

    final xValues = List.generate(
      maxBin - minBin + 1,
      (index) => (minBin + index) * widget.binWidth,
    );

    final seriesTotals = <int, int>{};
    if (widget.usePercentages) {
      for (int i = 0; i < widget.series.length; i++) {
        seriesTotals[i] = widget.series[i].values.length;
      }
    }

    final groups = <_ChartGroupData>[];

    for (final x in xValues) {
      final bars = <_BarData>[];

      for (
        int seriesIndex = 0;
        seriesIndex < widget.series.length;
        seriesIndex++
      ) {
        final series = widget.series[seriesIndex];
        final barsData = series.getBarsData();
        final matchingData = barsData.where((data) => data.$1 == x).toList();

        if (matchingData.isNotEmpty) {
          final count = matchingData.first.$2;
          if (count > 0) {
            double displayValue;
            if (widget.usePercentages && seriesTotals[seriesIndex]! > 0) {
              displayValue = (count / seriesTotals[seriesIndex]!) * 100;
            } else {
              displayValue = count.toDouble();
            }
            bars.add(
              _BarData(
                seriesIndex: seriesIndex,
                seriesName: series.groupName,
                value: displayValue,
                rawCount: count, 
                color: getColorByIndex(seriesIndex),
              ),
            );
          }
        }
      }

      groups.add(_ChartGroupData(xValue: x, bars: bars));
    }

    return groups;
  }

  void _handleHover(
    Offset position,
    BoxConstraints constraints,
    List<_ChartGroupData> chartData,
  ) {
    final groupIndex = _findGroupAtPosition(position, constraints, chartData);
    if (groupIndex != _hoveredGroupIndex) {
      setState(() {
        _hoveredGroupIndex = groupIndex;
      });
    }
  }

  void _handleTap(
    Offset position,
    BoxConstraints constraints,
    List<_ChartGroupData> chartData,
  ) {
    final groupIndex = _findGroupAtPosition(position, constraints, chartData);
    setState(() {
      _hoveredGroupIndex = groupIndex;
      _tapPosition = groupIndex != null ? position : null;
    });
  }

  int? _findGroupAtPosition(
    Offset position,
    BoxConstraints constraints,
    List<_ChartGroupData> chartData,
  ) {
    final bool isFullscreenHorizontal =
        widget.isFullscreenHistogram && widget.swapAxes;
    final bool isFullscreenVertical =
        widget.isFullscreenHistogram && widget.swapAxes && constraints.maxHeight > constraints.maxWidth;

    final leftPadding =
        widget.isExportMode
            ? 40.0
            : isFullscreenVertical
            ? 75.0
            : isFullscreenHorizontal
            ? 70.0
            : 60.0;
    final rightPadding = widget.isExportMode ? 10.0 : (isFullscreenVertical ? 10.0 : 20.0);
    final topPadding =
        widget.isExportMode
            ? 15.0
            : isFullscreenHorizontal
            ? 10.0
            : 20.0;
    final bottomPadding =
        widget.isExportMode
            ? 60.0
            : isFullscreenHorizontal
            ? 40.0
            : 80.0;

    final chartWidth = constraints.maxWidth - leftPadding - rightPadding;
    final chartHeight = constraints.maxHeight - topPadding - bottomPadding;

    if (position.dx < leftPadding ||
        position.dx > leftPadding + chartWidth ||
        position.dy < topPadding ||
        position.dy > topPadding + chartHeight) {
      return null;
    }

    if (widget.swapAxes) {
      final groupHeight = chartHeight / chartData.length;
      final relativeY = position.dy - topPadding;
      final indexFromBottom = (relativeY / groupHeight).floor();
      final groupIndex = chartData.length - 1 - indexFromBottom;

      if (groupIndex >= 0 && groupIndex < chartData.length) {
        return groupIndex;
      }
    } else {
      final groupWidth = chartWidth / chartData.length;
      final relativeX = position.dx - leftPadding;
      final groupIndex = (relativeX / groupWidth).floor();

      if (groupIndex >= 0 && groupIndex < chartData.length) {
        return groupIndex;
      }
    }

    return null;
  }

  Widget _buildTooltip(
    BuildContext context,
    _ChartGroupData groupData,
    Offset position,
    BoxConstraints constraints,
  ) {
    final loc = AppLocalizations.of(context)!;

    String caliber;
    if (widget.binWidth > 1) {
      final start = groupData.xValue.toInt();
      final end = (groupData.xValue + widget.binWidth).toInt();
      caliber = '$start-${end}mm';
    } else {
      caliber = '${groupData.xValue.toInt()}mm';
    }

    final totalCount = groupData.bars
        .map((b) => b.rawCount ?? b.value.toInt())
        .fold<int>(0, (sum, value) => sum + value);

    final fruitWord = totalCount != 1 ? loc.fruits : loc.fruit;

    const tooltipWidth = 160.0;

    final numBars = groupData.bars.length;
    final tooltipHeight =
        12 + 13 + 4 + 11 + 6 + (numBars * 14) + 12 + 16; // +16 para sombra

    double dx = position.dx + 10;
    double dy = position.dy - tooltipHeight - 10; // Intentar colocar arriba

    if (dy < 0) {
      dy = position.dy + 10;
    }

    if (dy + tooltipHeight > constraints.maxHeight) {
      dy = constraints.maxHeight - tooltipHeight;
    }

    dx = dx.clamp(0.0, math.max(0.0, constraints.maxWidth - tooltipWidth));

    dy = dy.clamp(0.0, math.max(0.0, constraints.maxHeight - tooltipHeight));

    return Positioned(
      left: dx,
      top: dy,
      child: SizedBox(
        width: tooltipWidth,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  caliber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: $totalCount $fruitWord',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ...groupData.bars.map((bar) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: bar.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bar.rawCount != null 
                              ? '${bar.seriesName}: ${bar.rawCount} (${bar.value.toStringAsFixed(1)}%)'
                              : '${bar.seriesName}: ${bar.value.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarData {
  _BarData({
    required this.seriesIndex,
    required this.seriesName,
    required this.value,
    required this.color,
    this.rawCount,
  });

  final int seriesIndex;
  final String seriesName;
  final double value;
  final Color color;
  final int? rawCount;
}

class _ChartGroupData {
  _ChartGroupData({required this.xValue, required this.bars});

  final double xValue;
  final List<_BarData> bars;
}

class _GroupedBarChartPainter extends CustomPainter {
  _GroupedBarChartPainter({
    required this.chartData,
    required this.series,
    required this.binWidth,
    required this.hoveredGroupIndex,
    required this.isExportMode,
    required this.isFullscreenHistogram,
    required this.swapAxes,
    required this.usePercentages,
    required this.xAxisLabel,
    required this.yAxisLabel,
  });

  final List<_ChartGroupData> chartData;
  final List<BarChartSeries> series;
  final double binWidth;
  final int? hoveredGroupIndex;
  final bool isExportMode;
  final bool isFullscreenHistogram;
  final bool swapAxes;
  final bool usePercentages;
  final String xAxisLabel;
  final String yAxisLabel;

  double _calculateDynamicBarWidth(double groupWidth) {
    const idealBarWidth = 8.0;
    const barSpacing = 2.5;

    int maxBarCount = 0;
    for (final group in chartData) {
      if (group.bars.length > maxBarCount) {
        maxBarCount = group.bars.length;
      }
    }

    if (maxBarCount == 0) return idealBarWidth;

    final idealTotalWidth =
        (maxBarCount * idealBarWidth) + ((maxBarCount - 1) * barSpacing);

    final availableWidth = groupWidth * 0.80;

    if (idealTotalWidth > availableWidth) {
      final reducedWidth =
          (availableWidth - ((maxBarCount - 1) * barSpacing)) / maxBarCount;
      return math.max(2.0, reducedWidth);
    } else {
      return idealBarWidth;
    }
  }

  double _calculateDynamicBarHeight(double groupHeight) {
    const idealBarHeight = 8.0;
    const barSpacing = 2.5;

    int maxBarCount = 0;
    for (final group in chartData) {
      if (group.bars.length > maxBarCount) {
        maxBarCount = group.bars.length;
      }
    }

    if (maxBarCount == 0) return idealBarHeight;

    final idealTotalHeight =
        (maxBarCount * idealBarHeight) + ((maxBarCount - 1) * barSpacing);

    final availableHeight = groupHeight * 0.80;

    if (idealTotalHeight > availableHeight) {
      final reducedHeight =
          (availableHeight - ((maxBarCount - 1) * barSpacing)) / maxBarCount;
      return math.max(2.0, reducedHeight);
    } else {
      return idealBarHeight;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (chartData.isEmpty) return;

    final bool isFullscreenHorizontal = isFullscreenHistogram && swapAxes;
    final bool isFullscreenVertical = isFullscreenHistogram && swapAxes && size.height > size.width;

    final leftPadding =
        isExportMode
            ? 40.0
            : isFullscreenVertical
            ? 75.0
            : isFullscreenHorizontal
            ? 70.0
            : 60.0;
    final rightPadding = isExportMode ? 10.0 : (isFullscreenVertical ? 10.0 : 20.0);
    final topPadding =
        isExportMode
            ? 15.0
            : isFullscreenHorizontal
            ? 10.0
            : 20.0;
    final bottomPadding =
        isExportMode
            ? 60.0
            : isFullscreenHorizontal
            ? 40.0
            : 80.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final maxValue = chartData
        .expand((group) => group.bars.map((bar) => bar.value))
        .fold<double>(0, (max, value) => value > max ? value : max);

    final List<int> yTicks;
    final double maxTick;
    if (usePercentages) {
      yTicks = [0, 25, 50, 75, 100];
      maxTick = 100.0;
    } else {
      yTicks = calculateYTicks(
        maxValue.toInt(),
        maxTicks: isFullscreenHistogram ? 5 : null,
      );
      maxTick = yTicks.isEmpty ? maxValue : yTicks.last.toDouble();
    }
    final yScale = chartHeight / maxTick;

    _drawHorizontalGrid(
      canvas,
      size,
      leftPadding,
      rightPadding,
      topPadding,
      bottomPadding,
      chartWidth,
      chartHeight,
      yTicks,
      maxTick,
    );

    _drawBars(canvas, chartWidth, chartHeight, leftPadding, topPadding, yScale);

    _drawAxes(
      canvas,
      size,
      leftPadding,
      topPadding,
      bottomPadding,
      chartWidth,
      chartHeight,
    );

    _drawXLabels(
      canvas,
      size,
      leftPadding,
      topPadding,
      chartWidth,
      chartHeight,
    );

    _drawYLabels(canvas, size, leftPadding, topPadding, chartHeight, yTicks, maxTick);

    _drawAxisTitles(
      canvas,
      size,
      leftPadding,
      topPadding,
      bottomPadding,
      chartHeight,
    );
  }

  void _drawHorizontalGrid(
    Canvas canvas,
    Size size,
    double leftPadding,
    double rightPadding,
    double topPadding,
    double bottomPadding,
    double chartWidth,
    double chartHeight,
    List<int> ticks,
    double maxTick,
  ) {
    final dashPaint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.2)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    if (swapAxes) {
      for (final tick in ticks) {
        final x = leftPadding + (tick * chartWidth / maxTick);

        _drawDashedLine(
          canvas,
          Offset(x, topPadding),
          Offset(x, topPadding + chartHeight),
          dashPaint,
        );
      }
    } else {
      for (final tick in ticks) {
        final y = topPadding + chartHeight - (tick * chartHeight / maxTick);

        _drawDashedLine(
          canvas,
          Offset(leftPadding, y),
          Offset(leftPadding + chartWidth, y),
          dashPaint,
        );
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final t1 = i * (dashWidth + dashSpace) / distance;
      final t2 = (i * (dashWidth + dashSpace) + dashWidth) / distance;
      canvas.drawLine(
        Offset.lerp(start, end, t1)!,
        Offset.lerp(start, end, t2)!,
        paint,
      );
    }
  }

  void _drawBars(
    Canvas canvas,
    double chartWidth,
    double chartHeight,
    double leftPadding,
    double topPadding,
    double yScale,
  ) {
    if (!swapAxes) {
      _drawVerticalBars(
        canvas,
        chartWidth,
        chartHeight,
        leftPadding,
        topPadding,
        yScale,
      );
    } else {
      _drawHorizontalBars(
        canvas,
        chartWidth,
        chartHeight,
        leftPadding,
        topPadding,
        yScale,
      );
    }
  }

  void _drawVerticalBars(
    Canvas canvas,
    double chartWidth,
    double chartHeight,
    double leftPadding,
    double topPadding,
    double yScale,
  ) {
    final groupWidth = chartWidth / chartData.length;

    final maxBarWidth = _calculateDynamicBarWidth(groupWidth);
    const barSpacing = 2.5;

    for (int groupIndex = 0; groupIndex < chartData.length; groupIndex++) {
      final group = chartData[groupIndex];
      final barCount = group.bars.length;

      if (barCount == 0) continue;

      final totalBarsWidth =
          (barCount * maxBarWidth) + ((barCount - 1) * barSpacing);

      final groupStartX =
          leftPadding +
          (groupIndex * groupWidth) +
          ((groupWidth - totalBarsWidth) / 2);

      final isHovered = groupIndex == hoveredGroupIndex;

      for (int barIndex = 0; barIndex < group.bars.length; barIndex++) {
        final bar = group.bars[barIndex];
        final barX = groupStartX + (barIndex * (maxBarWidth + barSpacing));
        final barHeight = bar.value * yScale;
        final barY = topPadding + chartHeight - barHeight;

        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, maxBarWidth, barHeight),
          const Radius.circular(4),
        );

        final barPaint =
            Paint()
              ..color = bar.color.withValues(alpha: isHovered ? 0.9 : 0.85)
              ..style = PaintingStyle.fill;
        canvas.drawRRect(barRect, barPaint);

        final borderPaint =
            Paint()
              ..color = bar.color.withValues(alpha: isHovered ? 1.0 : 0.7)
              ..strokeWidth = isHovered ? 2.0 : 1.0
              ..style = PaintingStyle.stroke;
        canvas.drawRRect(barRect, borderPaint);

        if (isHovered && !isExportMode) {
          final glowPaint =
              Paint()
                ..color = Colors.white.withValues(alpha: 0.2)
                ..style = PaintingStyle.fill;
          canvas.drawRRect(barRect, glowPaint);
        }
      }
    }
  }

  void _drawHorizontalBars(
    Canvas canvas,
    double chartWidth,
    double chartHeight,
    double leftPadding,
    double topPadding,
    double yScale,
  ) {
    final groupHeight = chartHeight / chartData.length;
    
    final double effectiveMaxValue;
    if (usePercentages) {
      effectiveMaxValue = 100.0;
    } else {
      effectiveMaxValue = chartData
          .expand((group) => group.bars.map((bar) => bar.value))
          .fold<double>(0, (max, value) => value > max ? value : max);
    }
    final xScale = effectiveMaxValue > 0 ? chartWidth / effectiveMaxValue : 1.0;

    final maxBarHeight = _calculateDynamicBarHeight(groupHeight);
    const barSpacing = 2.5;

    for (int groupIndex = 0; groupIndex < chartData.length; groupIndex++) {
      final group = chartData[groupIndex];
      final barCount = group.bars.length;

      if (barCount == 0) continue;

      final totalBarsHeight =
          (barCount * maxBarHeight) + ((barCount - 1) * barSpacing);

      final indexFromBottom = chartData.length - 1 - groupIndex;
      final groupStartY =
          topPadding +
          (indexFromBottom * groupHeight) +
          ((groupHeight - totalBarsHeight) / 2);

      final isHovered = groupIndex == hoveredGroupIndex;

      for (int barIndex = 0; barIndex < group.bars.length; barIndex++) {
        final bar = group.bars[barIndex];
        final barY = groupStartY + (barIndex * (maxBarHeight + barSpacing));
        final barWidth = bar.value * xScale;
        final barX = leftPadding;

        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barWidth, maxBarHeight),
          const Radius.circular(4),
        );

        final barPaint =
            Paint()
              ..color = bar.color.withValues(alpha: isHovered ? 0.9 : 0.85)
              ..style = PaintingStyle.fill;
        canvas.drawRRect(barRect, barPaint);

        final borderPaint =
            Paint()
              ..color = bar.color.withValues(alpha: isHovered ? 1.0 : 0.7)
              ..strokeWidth = isHovered ? 2.0 : 1.0
              ..style = PaintingStyle.stroke;
        canvas.drawRRect(barRect, borderPaint);

        if (isHovered && !isExportMode) {
          final glowPaint =
              Paint()
                ..color = Colors.white.withValues(alpha: 0.2)
                ..style = PaintingStyle.fill;
          canvas.drawRRect(barRect, glowPaint);
        }
      }
    }
  }

  void _drawAxes(
    Canvas canvas,
    Size size,
    double leftPadding,
    double topPadding,
    double bottomPadding,
    double chartWidth,
    double chartHeight,
  ) {
    final axisPaint =
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, topPadding + chartHeight),
      axisPaint,
    );

    canvas.drawLine(
      Offset(leftPadding, topPadding + chartHeight),
      Offset(leftPadding + chartWidth, topPadding + chartHeight),
      axisPaint,
    );
  }

  void _drawXLabels(
    Canvas canvas,
    Size size,
    double leftPadding,
    double topPadding,
    double chartWidth,
    double chartHeight,
  ) {
    if (swapAxes) {
      _drawXLabelsHorizontal(
        canvas,
        chartWidth,
        chartHeight,
        leftPadding,
        topPadding,
      );
      return;
    }

    final groupWidth = chartWidth / chartData.length;

    for (int i = 0; i < chartData.length; i++) {
      final group = chartData[i];
      String label;

      final binStart = group.xValue;
      final binEnd = group.xValue + binWidth;

      if (binWidth > 1) {
        label = '${binStart.toInt()}-${binEnd.toInt()}';
      } else {
        label = '${binStart.toInt()}';
      }

      final centerX = leftPadding + (i * groupWidth) + (groupWidth / 2);
      final axisY = topPadding + chartHeight;

      final tickPaintRange =
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke;

      final rangeLinePaint =
          Paint()
            ..color = Colors.grey.withValues(alpha: 0.2)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

      final rangeBarPaint =
          Paint()
            ..color = Colors.black87.withValues(alpha: 0.6)
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;

      final boxWidth = groupWidth * 0.85;
      final groupCenterX = leftPadding + (i * groupWidth) + (groupWidth / 2);

      final rangeLeftX = groupCenterX - (boxWidth / 2);
      final rangeRightX = groupCenterX + (boxWidth / 2);

      canvas.drawLine(
        Offset(rangeLeftX, topPadding),
        Offset(rangeLeftX, axisY),
        rangeLinePaint,
      );

      canvas.drawLine(
        Offset(rangeRightX, topPadding),
        Offset(rangeRightX, axisY),
        rangeLinePaint,
      );

      canvas.drawLine(
        Offset(rangeLeftX, axisY),
        Offset(rangeLeftX, axisY + 10),
        tickPaintRange,
      );

      canvas.drawLine(
        Offset(rangeRightX, axisY),
        Offset(rangeRightX, axisY + 10),
        tickPaintRange,
      );

      canvas.drawLine(
        Offset(rangeLeftX, axisY + 10),
        Offset(rangeRightX, axisY + 10),
        rangeBarPaint,
      );

      final centerTickPaint =
          Paint()
            ..color = Colors.grey.withValues(alpha: 0.5)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(centerX, axisY),
        Offset(centerX, axisY + 6),
        centerTickPaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: isExportMode ? 7 : 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final y =
          binWidth > 1 ? axisY + 28 : axisY + 24; // Aumentado de 20/16 a 28/24

      canvas.save();
      canvas.translate(centerX, y);
      canvas.rotate(-math.pi / 4);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
      canvas.restore();
    }
  }

  void _drawYLabels(
    Canvas canvas,
    Size size,
    double leftPadding,
    double topPadding,
    double chartHeight,
    List<int> yTicks,
    double maxTick,
  ) {
    if (swapAxes) {
      _drawYLabelsHorizontal(
        canvas,
        size,
        leftPadding,
        topPadding,
        chartHeight,
        maxTick,
      );
    } else {
      _drawYLabelsVertical(
        canvas,
        size,
        leftPadding,
        topPadding,
        chartHeight,
        yTicks,
        maxTick,
      );
    }
  }

  void _drawYLabelsVertical(
    Canvas canvas,
    Size size,
    double leftPadding,
    double topPadding,
    double chartHeight,
    List<int> yTicks,
    double maxTick,
  ) {
    for (final tick in yTicks) {
      final y = topPadding + chartHeight - (tick * chartHeight / maxTick);

      // Add % suffix in percentage mode
      final labelText = usePercentages ? '$tick%' : '$tick';

      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            color: Colors.black87,
            fontSize: isExportMode ? 9 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  void _drawYLabelsHorizontal(
    Canvas canvas,
    Size size,
    double leftPadding,
    double topPadding,
    double chartHeight,
    double maxTick,
  ) {
    final groupHeight = chartHeight / chartData.length;

    for (int i = 0; i < chartData.length; i++) {
      final group = chartData[i];
      final binStart = group.xValue;
      final binEnd = group.xValue + binWidth;

      final label =
          binWidth > 1
              ? '${binStart.toInt()}-${binEnd.toInt()}'
              : '${binStart.toInt()}';

      final indexFromBottom = chartData.length - 1 - i;

      final boxHeight = groupHeight * 0.85;
      final groupCenterY =
          topPadding + (indexFromBottom * groupHeight) + (groupHeight / 2);

      final rangeTopY = groupCenterY - (boxHeight / 2);
      final rangeBottomY = groupCenterY + (boxHeight / 2);

      final centerY = groupCenterY;

      final rangeLinePaint =
          Paint()
            ..color = Colors.grey.withValues(alpha: 0.2)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

      final tickPaintRange =
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke;

      final rangeBarPaint =
          Paint()
            ..color = Colors.black87.withValues(alpha: 0.6)
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(leftPadding, rangeTopY),
        Offset(size.width - 20, rangeTopY),
        rangeLinePaint,
      );

      canvas.drawLine(
        Offset(leftPadding, rangeBottomY),
        Offset(size.width - 20, rangeBottomY),
        rangeLinePaint,
      );

      canvas.drawLine(
        Offset(leftPadding, rangeTopY),
        Offset(leftPadding - 10, rangeTopY),
        tickPaintRange,
      );

      canvas.drawLine(
        Offset(leftPadding, rangeBottomY),
        Offset(leftPadding - 10, rangeBottomY),
        tickPaintRange,
      );

      canvas.drawLine(
        Offset(leftPadding - 10, rangeTopY),
        Offset(leftPadding - 10, rangeBottomY),
        rangeBarPaint,
      );

      final centerTickPaint =
          Paint()
            ..color = Colors.grey.withValues(alpha: 0.5)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(leftPadding, centerY),
        Offset(leftPadding - 6, centerY),
        centerTickPaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: isExportMode ? 8 : 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          leftPadding - textPainter.width - 15,
          centerY - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawXLabelsHorizontal(
    Canvas canvas,
    double chartWidth,
    double chartHeight,
    double leftPadding,
    double topPadding,
  ) {
    // In percentage mode, use fixed 0-100 scale; otherwise calculate from data
    final List<int> xTicks;
    final double maxTick;
    
    if (usePercentages) {
      xTicks = [0, 25, 50, 75, 100];
      maxTick = 100.0;
    } else {
      final maxValue = chartData
          .expand((group) => group.bars.map((bar) => bar.value))
          .fold<double>(0, (max, value) => value > max ? value : max);
      xTicks = calculateYTicks(maxValue.toInt(), maxTicks: null);
      maxTick = xTicks.isEmpty ? maxValue : xTicks.last.toDouble();
    }

    for (final tick in xTicks) {
      final x = leftPadding + (tick * chartWidth / maxTick);
      final axisY = topPadding + chartHeight;

      // Add % suffix in percentage mode
      final labelText = usePercentages ? '$tick%' : '$tick';

      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            color: Colors.black87,
            fontSize: isExportMode ? 8 : 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();

      textPainter.paint(canvas, Offset(x - textPainter.width / 2, axisY + 8));
    }
  }

  void _drawAxisTitles(
    Canvas canvas,
    Size size,
    double leftPadding,
    double topPadding,
    double bottomPadding,
    double chartHeight,
  ) {
    final effectiveYLabel = swapAxes ? xAxisLabel : yAxisLabel;
    final effectiveXLabel = swapAxes ? yAxisLabel : xAxisLabel;

    final yTitlePainter = TextPainter(
      text: TextSpan(
        text: effectiveYLabel,
        style: TextStyle(
          color: Colors.black87,
          fontSize: isExportMode ? 11 : 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    yTitlePainter.layout();

    final bool isFullscreenSwap = isFullscreenHistogram && swapAxes;
    final bool isFullscreenVertical = isFullscreenHistogram && swapAxes && size.height > size.width;

    final yTitleX =
        isExportMode
            ? 5.0
            : isFullscreenVertical
            ? leftPadding * 0.1
            : isFullscreenSwap
            ? leftPadding * 0.18
            : 8.0;

    canvas.save();
    canvas.translate(yTitleX, topPadding + chartHeight / 2);
    canvas.rotate(-math.pi / 2);
    yTitlePainter.paint(canvas, Offset(-yTitlePainter.width / 2, 0));
    canvas.restore();

    final xTitlePainter = TextPainter(
      text: TextSpan(
        text: effectiveXLabel,
        style: TextStyle(
          color: Colors.black87,
          fontSize: isExportMode ? 11 : 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    xTitlePainter.layout();

    final chartBottom = size.height - bottomPadding;
    final bool isFullscreenVerticalForX = isFullscreenHistogram && swapAxes && size.height > size.width;
    final xTitleY =
        isFullscreenVerticalForX
            ? chartBottom + (bottomPadding - xTitlePainter.height) * 1.1
            : isFullscreenSwap
            ? chartBottom + (bottomPadding - xTitlePainter.height) * 0.7
            : size.height - 6 - xTitlePainter.height;

    xTitlePainter.paint(canvas, Offset(leftPadding, xTitleY));
  }

  @override
  bool shouldRepaint(covariant _GroupedBarChartPainter oldDelegate) {
    return oldDelegate.chartData != chartData ||
        oldDelegate.hoveredGroupIndex != hoveredGroupIndex ||
        oldDelegate.binWidth != binWidth;
  }
}
