import 'package:dartx/dartx.dart';
import 'package:fruit_measure_app/domains/charts/models/custom_flspot.dart';
import 'package:fruit_measure_app/domains/plots/models/group_of_plots_values.dart';

class PlotChartSeries {
  PlotChartSeries({required this.plots}) {
    _initData();
  }

  final List<GroupOfPlotsValues> plots;

  late final List<CustomFlSpot> curveSpots = [];

  void _initData() {
    if (plots.isNotEmpty) {
      for (int m = 0; m < plots.length; m++) {
        final calibersValues = plots[m].getCalibers().values.toList();
        for (int d = 0; d < calibersValues.length; d++) {
          final value = calibersValues[d];
          curveSpots.add(CustomFlSpot(d.toDouble(), value, plots[m].name));
        }
      }
    }
  }

  List<DateTime> takeLastDates(List<GroupOfPlotsValues> measurements) {
    const int maxDate = 10;

    final Set<DateTime> allDates =
        measurements.expand((instance) => instance.getCalibers().keys).toSet();

    return (allDates.toList()..sort()).takeLast(maxDate);
  }

  String toCsv() {
    final buffer = StringBuffer();

    final List<_CsvRow> rows = [];

    for (final plot in plots) {
      final calibers = plot.getCalibers();
      for (final entry in calibers.entries) {
        rows.add(
          _CsvRow(date: entry.key, caliber: entry.value, plotName: plot.name),
        );
      }
    }

    rows.sort((a, b) => a.date.compareTo(b.date));

    for (final row in rows) {
      final formattedDate =
          '${row.date.day.toString().padLeft(2, '0')}/${row.date.month.toString().padLeft(2, '0')}/${row.date.year}';

      final formattedCaliber = row.caliber.toStringAsFixed(2);

      final plotName =
          row.plotName.contains(',') || row.plotName.contains('"')
              ? '"${row.plotName.replaceAll('"', '""')}"'
              : row.plotName;

      buffer.writeln('$formattedDate,$formattedCaliber,$plotName');
    }

    return buffer.toString();
  }

  Map<String, double> calculateGrowthCurve() {
    final Map<String, double> growthMap = {};

    for (final instance in plots) {
      final entries = instance.getCalibers().entries.toList();
      if (entries.length >= 2) {
        final last = entries.last;
        final prev = entries[entries.length - 2];
        final delta = last.key.difference(prev.key).inDays;
        if (delta > 0) {
          final rate = (last.value - prev.value) / delta;
          growthMap[instance.name] = rate;
        }
      }
    }

    return growthMap;
  }

  List<DateTime> getLatestMeasurementDates() {
    final Set<DateTime> allDates =
        plots.expand((instance) => instance.getCalibers().keys).toSet();

    return (allDates.toList()..sort());
  }
}

class _CsvRow {
  _CsvRow({required this.date, required this.caliber, required this.plotName});

  final DateTime date;
  final double caliber;
  final String plotName;
}
