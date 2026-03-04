import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/domains/charts/models/chart_type_enum.dart';
import 'package:fruit_measure_app/domains/charts/models/plot_chart_series.dart';
import 'package:fruit_measure_app/domains/charts/views/growth_line_chart_component.dart';
import 'package:fruit_measure_app/domains/charts/views/share_chart_button.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/plots/models/group_of_plots_values.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/get_color_by_index.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:hive_ce/hive.dart';

class MeasurementsMultiGrowthCurveStatisticsViewArguments {
  MeasurementsMultiGrowthCurveStatisticsViewArguments({required this.plots});

  final List<Plot> plots;
}

class MeasurementsMultiGrowthCurveStatisticsView extends StatefulWidget {
  const MeasurementsMultiGrowthCurveStatisticsView({
    super.key,
    required this.plots,
  });

  final List<Plot> plots;

  @override
  State<MeasurementsMultiGrowthCurveStatisticsView> createState() =>
      _MeasurementsMultiGrowthCurveStatisticsViewState();
}

class _MeasurementsMultiGrowthCurveStatisticsViewState
    extends State<MeasurementsMultiGrowthCurveStatisticsView>
    with UpdateState<MeasurementsMultiGrowthCurveStatisticsView> {
  final GlobalKey _measurementsMultiChartKey = GlobalKey();
  bool _navigationPending = false;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      if (!_navigationPending) {
        _navigationPending = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        });
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final measurementBox = Hive.box<Measurement>(measurementBoxName);

    final List<GroupOfPlotsValues> listOfPlotsValues =
        widget.plots.map((plot) {
          final mAssocWithPlot =
              measurementBox.values
                  .where((m) => m.plotId == plot.id)
                  .sortedBy((m) => m.creationDate)
                  .toList();

          return GroupOfPlotsValues(
            name: plot.name,
            measurements: mAssocWithPlot,
          );
        }).toList();

    final PlotChartSeries series = PlotChartSeries(plots: listOfPlotsValues);

    final Map<String, double> growthRateMap = series.calculateGrowthCurve();

    final bool isMultiChart = listOfPlotsValues.length > 1;

    return Scaffold(
      appBar: CustomAppBar(title: loc.growthCurve),
      endDrawer: const AccountEndDrawer(),
      drawerBarrierDismissible: false,
      endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMultiChart) ...[
              Text(
                listOfPlotsValues.first.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
              ),
            ],
            RepaintBoundary(
              key: _measurementsMultiChartKey,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.temporalEvolutionPlot,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child:
                            series.plots.isNotEmpty
                                ? GrowthLineChartComponent(series: series)
                                : Center(child: Text(loc.withoutData)),
                      ),
                      if (series.plots.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              loc.tapPointsForDetails,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.statistics,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...listOfPlotsValues.map((e) {
              final i = listOfPlotsValues.indexOf(e);
              final growthRate = growthRateMap[e.name] ?? 0;
              return _buildGrowthCard(
                e.name,
                growthRate,
                isMultiChart ? i : null,
              );
            }),
          ],
        ),
      ),

      bottomNavigationBar: SizedBox(
        height: 100,
        child: Stack(
          children: [
            Positioned(
              right: 24,
              bottom: 24,
              child: ShareChartButton(
                repaintKey: _measurementsMultiChartKey,
                chartType: ChartType.plotChart,
                textToExport: [series.toCsv()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthCard(String name, double growthRate, int? index) {
    final loc = AppLocalizations.of(context)!;

    final MaterialColor color =
        index != null ? getColorByIndex(index) : Colors.grey;

    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.shade50,
              border: Border.all(color: color.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  loc.currentGrowthRate,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!(growthRate == 0))
                      Icon(
                        growthRate > 0
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: growthRate > 0 ? Colors.green : Colors.red,
                        size: 30,
                      ),

                    Text(
                      ' ${growthRate.toStringAsFixed(2)} ${loc.millimetersDay}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
