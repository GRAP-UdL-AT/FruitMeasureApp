import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruit_measure_app/components/colors.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/domains/charts/models/bar_chart_series.dart';
import 'package:fruit_measure_app/domains/charts/models/chart_type_enum.dart';
import 'package:fruit_measure_app/domains/charts/views/diameter_chart_component.dart';
import 'package:fruit_measure_app/domains/charts/views/share_chart_button.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurements_histogram_full_view.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/get_photo_complete.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:intl/intl.dart';

class PhotosStatisticsViewArguments {
  PhotosStatisticsViewArguments({
    required this.plot,
    required this.measurement,
  });

  final Plot plot;
  final Measurement measurement;
}

class PhotosStatisticsView extends StatefulWidget {
  const PhotosStatisticsView({
    super.key,
    required this.plot,
    required this.measurement,
  });

  final Plot plot;
  final Measurement measurement;

  @override
  State<PhotosStatisticsView> createState() => _PhotosStatisticsViewState();
}

class _PhotosStatisticsViewState extends State<PhotosStatisticsView>
    with UpdateState<PhotosStatisticsView> {
  final GlobalKey _photoChartKey = GlobalKey();
  final GlobalKey _chartComponentKey = GlobalKey();
  bool _isExpandedMode = false;
  bool _isCapturingImage = false;
  double _selectedBinWidth = 1.0;
  double? _minBinWidthForCompact;
  bool _usePercentages = true;

  Future<List<PhotoComplete>>? _cachedPhotosFuture;
  List<double>? _cachedCalibers;
  BarChartSeries? _cachedBar;
  double? _cachedMin;
  double? _cachedMax;
  double? _cachedAvg;
  int? _cachedNumberOfImages;
  int? _cachedNumberOfFruits;
  double? _cachedAvgFruitsPerImage;
  String? _lastMeasurementId;
  String? _lastMeasurementName;
  int _cacheVersion = 0;

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

  void _invalidateCache() {
    _cachedPhotosFuture = getPhotoComplete(
      measurementId: widget.measurement.id,
    );
    _cachedCalibers = null;
    _cachedBar = null;
    _cachedMin = null;
    _cachedMax = null;
    _cachedAvg = null;
    _cachedNumberOfImages = null;
    _cachedNumberOfFruits = null;
    _cachedAvgFruitsPerImage = null;
    _lastMeasurementName = null;
    _cacheVersion++;
  }

  @override
  void initState() {
    super.initState();
    _cachedPhotosFuture = getPhotoComplete(
      measurementId: widget.measurement.id,
    );
    _lastMeasurementId = widget.measurement.id;
    _lastMeasurementName = widget.measurement.name;
  }

  @override
  void didUpdateWidget(PhotosStatisticsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.measurement.id != widget.measurement.id ||
        oldWidget.measurement.name != widget.measurement.name) {
      _invalidateCache();
      _lastMeasurementId = widget.measurement.id;
      _lastMeasurementName = widget.measurement.name;
    }
  }

  void _calculateAndCacheStats(List<PhotoComplete> photos) {
    if (_cachedCalibers != null &&
        _lastMeasurementId == widget.measurement.id &&
        _lastMeasurementName == widget.measurement.name) {
      return;
    }

    _cachedCalibers =
        photos
            .expand(
              (photo) => photo.detections.map((detection) => detection.caliber),
            )
            .where((caliber) => caliber > 0)
            .toList()
          ..sort();

    _cachedBar = BarChartSeries(
      groupName: widget.measurement.name ?? '',
      values: _cachedCalibers!,
    );

    _cachedMin = _cachedCalibers!.firstOrNull;
    _cachedMax = _cachedCalibers!.lastOrNull;
    _cachedAvg =
        _cachedCalibers!.isNotEmpty ? _cachedCalibers!.average() : null;

    _cachedNumberOfImages = photos.length;
    _cachedNumberOfFruits = photos.expand((photo) => photo.detections).length;
    _cachedAvgFruitsPerImage =
        _cachedNumberOfImages! > 0
            ? _cachedNumberOfFruits! / _cachedNumberOfImages!
            : 0.0;

    _lastMeasurementId = widget.measurement.id;
    _lastMeasurementName = widget.measurement.name;
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

    final Measurement assocMeasurement = widget.measurement;

    return FutureBuilder<List<PhotoComplete>>(
      key: ValueKey<int>(_cacheVersion),
      future: _cachedPhotosFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final List<PhotoComplete> photos = snapshot.data!;

        _calculateAndCacheStats(photos);

        final List<double> calibers = _cachedCalibers!;
        final bar = _cachedBar!;
        final min = _cachedMin;
        final max = _cachedMax;
        final avg = _cachedAvg;
        final numberOfImages = _cachedNumberOfImages!;
        final numberOfFruits = _cachedNumberOfFruits!;
        final avgFruitsPerImage = _cachedAvgFruitsPerImage!;

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
                Text(
                  widget.plot.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'dd/MM/yyyy',
                  ).format(assocMeasurement.creationDate),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  assocMeasurement.model?.getModelName(loc) ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RepaintBoundary(
                          key: _photoChartKey,
                          child: Card(
                            color: fmaWhiteComplementary,
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
                                  Text(
                                    '${loc.caliberSeasonText} - ${DateFormat('dd/MM/yyyy').format(assocMeasurement.creationDate)}',
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
                                                  fontWeight: FontWeight.w500,
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
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                  child: Builder(
                                                    builder: (context) {
                                                      double effectiveValue =
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
                                                        value: effectiveValue,
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
                                                                value: width,
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
                                                          if (value != null) {
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
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
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
                                                          Colors.grey.shade300,
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
                                                  MaterialPageRoute<void>(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => MeasurementsHistogramFullView(
                                                          bars: [bar],
                                                          originalOrientations:
                                                              const [
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
                                                      ? loc.tooltipScrollMode
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
                                  SizedBox(height: _isCapturingImage ? 4 : 12),

                                  if (_isExpandedMode)
                                    SizedBox(
                                      height: 400,
                                      child:
                                          calibers.isNotEmpty
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

                                                  if (calibers.isNotEmpty) {
                                                    final maxValue =
                                                        calibers.last;

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
                                                    bars: [bar],
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
                                          calibers.isNotEmpty
                                              ? DiameterBarChartComponent(
                                                key: _chartComponentKey,
                                                bars: [bar],
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
                                                  }
                                                },
                                              )
                                              : Center(
                                                child: Text(loc.withoutData),
                                              ),
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
                        Row(
                          children: [
                            _buildStatCard(loc.caliberMin, min),
                            _buildStatCard(loc.caliberMax, max),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatCard(loc.caliberAvg, avg),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatCardNoUnit(
                              loc.numberOfImages,
                              numberOfImages,
                            ),
                            _buildStatCardNoUnit(
                              loc.numberOfFruits,
                              numberOfFruits,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatCardNoUnit(
                              loc.avgFruitsPerImage,
                              avgFruitsPerImage,
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
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
                    repaintKey: _photoChartKey,
                    chartComponentKey: _chartComponentKey,
                    chartType: ChartType.barChart,
                    textToExport: [bar.toCsv()],
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
      },
    );
  }

  Widget _buildStatCard(String label, num? value) {
    String formattedValue = 'mm';
    if (value != null) {
      final str = value.toStringAsFixed(1);
      formattedValue =
          str.endsWith('.0') ? str.substring(0, str.length - 2) : str;
      formattedValue = '$formattedValue mm';
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              formattedValue,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardNoUnit(String label, num? value) {
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

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              formattedValue,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
