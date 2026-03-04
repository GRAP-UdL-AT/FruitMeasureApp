import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/domains/charts/models/bar_chart_series.dart';
import 'package:fruit_measure_app/domains/charts/models/chart_type_enum.dart';
import 'package:fruit_measure_app/domains/charts/views/diameter_chart_component.dart';
import 'package:fruit_measure_app/domains/charts/views/share_chart_button.dart';
import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/measurements/models/group_of_measurements_values.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurements_histogram_full_view.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/get_color_by_index.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:hive_ce/hive.dart';

class MeasurementsStatisticsViewArguments {
  MeasurementsStatisticsViewArguments({required this.measurements});

  final List<Measurement> measurements;
}

class MeasurementsStadisticsView extends StatefulWidget {
  const MeasurementsStadisticsView({super.key, required this.measurements});

  final List<Measurement> measurements;

  @override
  State<MeasurementsStadisticsView> createState() =>
      _MeasurementsStadisticsViewState();
}

class _MeasurementsStadisticsViewState extends State<MeasurementsStadisticsView>
    with UpdateState<MeasurementsStadisticsView> {
  final GlobalKey _measurementsChartKey = GlobalKey();
  final GlobalKey _chartComponentKey = GlobalKey();
  bool _isExpandedMode = false;
  bool _isCapturingImage = false;
  double _selectedBinWidth = 1.0;
  double? _minBinWidthForCompact;
  bool _usePercentages = true;

  List<GroupOfMeasurementsValues>? _cachedMeasurementsInstances;
  List<BarChartSeries>? _cachedBars;
  bool _isLoading = true;
  bool _isLoadingData = false;

  List<PhotoComplete> _findPhotosCompletes({required String measurementId}) {
    final photos =
        Hive.box<Photo>(photoBoxName).values
            .where((photo) => photo.measurementId == measurementId)
            .toList();

    if (photos.isEmpty) {
      return [];
    }

    final photoIds = photos.map((p) => p.id).toList();

    final allDetections =
        Hive.box<Detection>(detectionsBoxName).values
            .where((detection) => photoIds.contains(detection.photoId))
            .toList();

    final detectionsByPhotoId = <String, List<Detection>>{};
    for (final detection in allDetections) {
      detectionsByPhotoId
          .putIfAbsent(detection.photoId, () => [])
          .add(detection);
    }

    final photosComplete =
        photos
            .map(
              (photo) => PhotoComplete(
                id: photo.id,
                measurementId: photo.measurementId,
                captureDate: photo.captureDate,
                creationDate: photo.creationDate,
                latitude: photo.latitude,
                longitude: photo.longitude,
                imagePath: photo.imagePath,
                detections: detectionsByPhotoId[photo.id] ?? [],
              ),
            )
            .toList();

    return photosComplete;
  }

  List<double> _getAvailableBinWidthOptions() {
    return const [1.0, 3.0, 5.0, 10.0, 15.0, 20.0];
  }

  void _adjustBinWidthIfNeeded() {
    if (_minBinWidthForCompact != null &&
        _selectedBinWidth < _minBinWidthForCompact! &&
        _isExpandedMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedBinWidth = _minBinWidthForCompact!;
          });
        }
      });
    }
  }

  bool _navigationPending = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(MeasurementsStadisticsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted || _isLoadingData) return;

    _isLoadingData = true;
    setState(() {
      _isLoading = true;
    });

    final measurements = widget.measurements;
    final List<GroupOfMeasurementsValues> measurementsInstances = [];

    for (final measurement in measurements) {
      measurementsInstances.add(
        GroupOfMeasurementsValues(
          name: '${measurement.name}',
          model: measurement.model,
          creationDate: measurement.creationDate,
          photos: _findPhotosCompletes(measurementId: measurement.id),
        ),
      );
    }

    final List<BarChartSeries> bars =
        measurementsInstances.map((m) {
          return BarChartSeries(
            groupName: m.name,
            values:
                m.photos
                    .expand((photo) => photo.detections)
                    .map((detection) => detection.caliber)
                    .whereNotNull()
                    .toList(),
          );
        }).toList();

    if (mounted) {
      setState(() {
        _cachedMeasurementsInstances = measurementsInstances;
        _cachedBars = bars;
        _isLoading = false;
        _isLoadingData = false;
      });
    } else {
      _isLoadingData = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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

    if (_isLoading || _cachedMeasurementsInstances == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<GroupOfMeasurementsValues> measurementsInstances =
        _cachedMeasurementsInstances!;
    final List<BarChartSeries> bars = _cachedBars!;

    return Scaffold(
      appBar: CustomAppBar(title: loc.statistics),
      endDrawer: const AccountEndDrawer(),
      drawerBarrierDismissible: false,
      endDrawerEnableOpenDragGesture: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Expanded(
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RepaintBoundary(
                          key: _measurementsChartKey,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: EdgeInsets.all(
                                _isCapturingImage ? 6 : 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${loc.caliberSeasonText} - ${loc.comparative}',
                                        style: TextStyle(
                                          fontSize: _isCapturingImage ? 11 : 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (!_isCapturingImage) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${loc.binWidthGrouping}:',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade300,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: DropdownButtonHideUnderline(
                                                      child: Builder(
                                                        builder: (context) {
                                                          double
                                                          effectiveValue =
                                                              _selectedBinWidth;
                                                          if (_isExpandedMode &&
                                                              _minBinWidthForCompact !=
                                                                  null &&
                                                              _selectedBinWidth <
                                                                  _minBinWidthForCompact!) {
                                                            effectiveValue =
                                                                _minBinWidthForCompact!;
                                                          }

                                                          return DropdownButton<
                                                            double
                                                          >(
                                                            value:
                                                                effectiveValue,
                                                            isDense: true,
                                                            items:
                                                                _getAvailableBinWidthOptions().map((
                                                                  width,
                                                                ) {
                                                                  final isDisabled =
                                                                      _isExpandedMode &&
                                                                      _minBinWidthForCompact !=
                                                                          null &&
                                                                      width <
                                                                          _minBinWidthForCompact!;

                                                                  return DropdownMenuItem<
                                                                    double
                                                                  >(
                                                                    value:
                                                                        width,
                                                                    enabled:
                                                                        !isDisabled,
                                                                    child: Text(
                                                                      '${width.toInt()}mm',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            isDisabled
                                                                                ? Colors.grey
                                                                                : Colors.black,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                            onChanged: (value) {
                                                              if (value !=
                                                                  null) {
                                                                setState(() {
                                                                  _selectedBinWidth =
                                                                      value;
                                                                });
                                                              }
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade300,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _usePercentages =
                                                                  true;
                                                            });
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  _usePercentages
                                                                      ? Colors
                                                                          .blue
                                                                          .shade100
                                                                      : Colors
                                                                          .transparent,
                                                              borderRadius:
                                                                  const BorderRadius.horizontal(
                                                                    left:
                                                                        Radius.circular(
                                                                          5,
                                                                        ),
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              '%',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    _usePercentages
                                                                        ? FontWeight
                                                                            .w600
                                                                        : FontWeight
                                                                            .w400,
                                                                color:
                                                                    _usePercentages
                                                                        ? Colors
                                                                            .blue
                                                                            .shade700
                                                                        : Colors
                                                                            .grey
                                                                            .shade600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 1,
                                                          height: 18,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _usePercentages =
                                                                  false;
                                                            });
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  !_usePercentages
                                                                      ? Colors
                                                                          .blue
                                                                          .shade100
                                                                      : Colors
                                                                          .transparent,
                                                              borderRadius:
                                                                  const BorderRadius.horizontal(
                                                                    right:
                                                                        Radius.circular(
                                                                          5,
                                                                        ),
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              'Nº',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    !_usePercentages
                                                                        ? FontWeight
                                                                            .w600
                                                                        : FontWeight
                                                                            .w400,
                                                                color:
                                                                    !_usePercentages
                                                                        ? Colors
                                                                            .blue
                                                                            .shade700
                                                                        : Colors
                                                                            .grey
                                                                            .shade600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.fullscreen,
                                                    size: 20,
                                                  ),
                                                  tooltip:
                                                      loc.tooltipViewFullscreen,
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => MeasurementsHistogramFullView(
                                                              bars: bars,
                                                              originalOrientations: const [
                                                                DeviceOrientation
                                                                    .portraitUp,
                                                              ],
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    _isExpandedMode
                                                        ? Icons.unfold_less
                                                        : Icons.unfold_more,
                                                    size: 20,
                                                  ),
                                                  tooltip:
                                                      _isExpandedMode
                                                          ? loc
                                                              .tooltipScrollMode
                                                          : loc.tooltipFullView,
                                                  onPressed: () {
                                                    setState(() {
                                                      _isExpandedMode =
                                                          !_isExpandedMode;
                                                    });
                                                    _adjustBinWidthIfNeeded();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: _isCapturingImage ? 4 : 12),
                                  if (_isExpandedMode)
                                    SizedBox(
                                      height: boxConstraints.maxHeight - 200,
                                      child:
                                          measurementsInstances.isNotEmpty
                                              ? LayoutBuilder(
                                                builder: (
                                                  context,
                                                  chartConstraints,
                                                ) {
                                                  final screenWidth =
                                                      chartConstraints
                                                          .maxWidth -
                                                      120;
                                                  double calculatedMinBinWidth =
                                                      1.0;

                                                  final allValues =
                                                      bars
                                                          .expand(
                                                            (s) => s.values,
                                                          )
                                                          .where((v) => v > 0)
                                                          .toList();
                                                  if (allValues.isNotEmpty) {
                                                    final maxValue = allValues
                                                        .reduce(
                                                          (a, b) =>
                                                              a > b ? a : b,
                                                        );

                                                    const binWidthOptions = [
                                                      1.0,
                                                      3.0,
                                                      5.0,
                                                      10.0,
                                                      15.0,
                                                      20.0,
                                                    ];
                                                    for (final binWidth
                                                        in binWidthOptions) {
                                                      final numBinsFull =
                                                          (maxValue / binWidth)
                                                              .ceil() +
                                                          1;
                                                      final double
                                                      minWidthPerValue =
                                                          binWidth == 1.0
                                                              ? 15.0
                                                              : binWidth == 3.0
                                                              ? 18.0
                                                              : binWidth == 5.0
                                                              ? 22.0
                                                              : 26.0;
                                                      final calculatedWidth =
                                                          numBinsFull *
                                                          minWidthPerValue;

                                                      if (calculatedWidth <=
                                                          screenWidth) {
                                                        calculatedMinBinWidth =
                                                            binWidth;
                                                        break;
                                                      }
                                                      calculatedMinBinWidth =
                                                          binWidth;
                                                    }
                                                  }

                                                  final effectiveBinWidth =
                                                      _selectedBinWidth <
                                                              calculatedMinBinWidth
                                                          ? calculatedMinBinWidth
                                                          : _selectedBinWidth;

                                                  if (_minBinWidthForCompact !=
                                                      calculatedMinBinWidth) {
                                                    WidgetsBinding.instance.addPostFrameCallback((
                                                      _,
                                                    ) {
                                                      if (mounted) {
                                                        setState(() {
                                                          _minBinWidthForCompact =
                                                              calculatedMinBinWidth;
                                                          if (_selectedBinWidth <
                                                              calculatedMinBinWidth) {
                                                            _selectedBinWidth =
                                                                calculatedMinBinWidth;
                                                          }
                                                        });
                                                      }
                                                    });
                                                  }

                                                  return DiameterBarChartComponent(
                                                    key: _chartComponentKey,
                                                    bars: bars,
                                                    initialBinWidth:
                                                        effectiveBinWidth,
                                                    showBinWidthSelector: false,
                                                    isExportMode: true,
                                                    showNavigationArrows: false,
                                                    showLegend: false,
                                                    usePercentages:
                                                        _usePercentages,
                                                  );
                                                },
                                              )
                                              : Center(
                                                child: Text(loc.withoutData),
                                              ),
                                    )
                                  else
                                    SizedBox(
                                      height: 320,
                                      child:
                                          measurementsInstances.isNotEmpty
                                              ? DiameterBarChartComponent(
                                                key: _chartComponentKey,
                                                bars: bars,
                                                initialBinWidth:
                                                    _selectedBinWidth,
                                                showBinWidthSelector: false,
                                                showLegend: false,
                                                usePercentages: _usePercentages,
                                                onRecommendedBinWidthChanged: (
                                                  recommendedBinWidth,
                                                ) {
                                                  if (_minBinWidthForCompact !=
                                                      recommendedBinWidth) {
                                                    setState(() {
                                                      _minBinWidthForCompact =
                                                          recommendedBinWidth;
                                                    });
                                                    _adjustBinWidthIfNeeded();
                                                  }
                                                },
                                              )
                                              : Center(
                                                child: Text(loc.withoutData),
                                              ),
                                    ),
                                  SizedBox(height: _isCapturingImage ? 4 : 16),
                                  if (bars.isNotEmpty)
                                    Wrap(
                                      spacing: _isCapturingImage ? 6 : 12,
                                      runSpacing: _isCapturingImage ? 3 : 8,
                                      children:
                                          bars.map((bar) {
                                            final color = getColorByIndex(
                                              bars.indexOf(bar),
                                            );
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width:
                                                      _isCapturingImage
                                                          ? 10
                                                          : 12,
                                                  height:
                                                      _isCapturingImage
                                                          ? 10
                                                          : 12,
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      _isCapturingImage ? 4 : 6,
                                                ),
                                                Text(
                                                  bar.groupName,
                                                  style: TextStyle(
                                                    fontSize:
                                                        _isCapturingImage
                                                            ? 10
                                                            : 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          loc.statistics,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Column(
                          children: [
                            const SizedBox(height: 6),
                            ...measurementsInstances.flatMap((e) {
                              final int i = measurementsInstances.indexWhere(
                                (m) => m.name == e.name,
                              );

                              return [_measurementsCard(e, i)];
                            }),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
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
                repaintKey: _measurementsChartKey,
                chartComponentKey: _chartComponentKey,
                chartType: ChartType.barChart,
                textToExport: bars.map((b) => b.toCsv()).toList(),
                onCaptureStart: () {
                  setState(() {
                    _isCapturingImage = true;
                  });
                },
                onCaptureEnd: () {
                  setState(() {
                    _isCapturingImage = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _measurementsCard(GroupOfMeasurementsValues instance, int? index) {
    final loc = AppLocalizations.of(context)!;

    final MaterialColor color =
        index != null ? getColorByIndex(index) : Colors.grey;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.category_outlined),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  instance.name,
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  instance.model != null
                      ? '${instance.model?.getModelName(loc)}'
                      : loc.noModel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Flexible(
                child: Text(
                  '${instance.creationDate.day}/${instance.creationDate.month}/${instance.creationDate.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              _buildRowStatCard(loc.caliberMax, instance.max()),
              _buildRowStatCard(loc.caliberMin, instance.min()),
              _buildRowStatCard(loc.caliberAvg, instance.avg()),
              _buildRowStatCardNoUnit(
                loc.numberOfImages,
                instance.numberOfPhotos(),
              ),
              _buildRowStatCardNoUnit(
                loc.numberOfFruits,
                instance.numberOfFruits(),
              ),
              _buildRowStatCardNoUnit(
                loc.avgFruitsPerImage,
                instance.averageFruitsPerPhoto(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowStatCard(String label, num? value) {
    final loc = AppLocalizations.of(context)!;
    String formattedValue = loc.millimetersUnit;
    if (value != null) {
      final str = value.toStringAsFixed(1);
      formattedValue =
          str.endsWith('.0') ? str.substring(0, str.length - 2) : str;
      formattedValue = '$formattedValue ${loc.millimetersUnit}';
    }

    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const Spacer(),
        Text(
          formattedValue,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRowStatCardNoUnit(String label, num? value) {
    String formattedValue = '-';
    if (value != null) {
      // For integers, show without decimals; for doubles, show 1 decimal
      if (value is int || value == value.roundToDouble()) {
        formattedValue = value.toInt().toString();
      } else {
        final str = value.toStringAsFixed(1);
        formattedValue =
            str.endsWith('.0') ? str.substring(0, str.length - 2) : str;
      }
    }

    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const Spacer(),
        Text(
          formattedValue,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
