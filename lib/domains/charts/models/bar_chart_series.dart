import 'package:fruit_measure_app/domains/charts/models/bar_chart_entry.dart';

class BarChartSeries {
  BarChartSeries({
    required this.groupName,
    required this.values,
    this.binWidth = 1.0,
  }) {
    _initData();
  }

  final String groupName;
  final List<double> values;
  final double binWidth;

  late final List<BarChartEntry> dataPoints;

  void _initData() {
    final Map<double, List<int>> grouped = {};

    for (final value in values) {
      final binKey = (value / binWidth).floor() * binWidth;
      grouped.putIfAbsent(binKey, () => <int>[]).add(1);
    }

    dataPoints =
        grouped.entries
            .map((e) => BarChartEntry(xValue: e.key, occurrences: e.value))
            .toList()
          ..sort((a, b) => a.xValue.compareTo(b.xValue));
  }

  BarChartSeries copyWith({double? binWidth}) {
    return BarChartSeries(
      groupName: groupName,
      values: values,
      binWidth: binWidth ?? this.binWidth,
    );
  }

  double get maxXValue =>
      dataPoints.isEmpty
          ? 0.0
          : dataPoints.map((p) => p.xValue).reduce((a, b) => a > b ? a : b);

  int get maxCount =>
      dataPoints.isEmpty
          ? 0
          : dataPoints.map((p) => p.count).reduce((a, b) => a > b ? a : b);

  List<(double xValue, int count)> getBarsData() {
    return [for (final point in dataPoints) (point.xValue, point.count)];
  }

  List<double> getSortedXValues() =>
      dataPoints.map((p) => p.xValue).toList()..sort();

  String toCsv() {
    final buffer = StringBuffer();
    for (final point in dataPoints) {
      buffer.writeln('$groupName,${point.xValue},${point.count}');
    }
    return buffer.toString();
  }

  @override
  String toString() {
    if (dataPoints.isEmpty) return 'BarData(grupo: "$groupName", sin datos)';

    final buffer = StringBuffer();
    buffer.writeln('BarData(grupo: "$groupName")');
    buffer.writeln('  Valores: [${values.length} elementos]');
    buffer.writeln('  Puntos: [');

    for (final point in dataPoints) {
      final barVisual = '■' * (point.count);
      buffer.writeln(
        '    ${point.xValue.toStringAsFixed(1)}: ${point.count} $barVisual',
      );
    }

    buffer.writeln('  ]');
    return buffer.toString();
  }
}
