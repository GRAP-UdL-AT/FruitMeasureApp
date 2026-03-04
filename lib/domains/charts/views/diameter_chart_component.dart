import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fruit_measure_app/domains/charts/models/bar_chart_series.dart';
import 'package:fruit_measure_app/domains/charts/views/custom_grouped_bar_chart.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/get_color_by_index.dart';

final ValueNotifier<bool> chartArrowVisibilityNotifier = ValueNotifier<bool>(
  true,
);

class _HistogramDiagnostics {
  _HistogramDiagnostics({
    required this.minValue,
    required this.maxValue,
    required this.range,
    required this.numBinsCompact,
    required this.numBinsFull,
    required this.maxCount,
    required this.isEmpty,
  });

  final double minValue;
  final double maxValue;
  final double range;
  final int numBinsCompact;
  final int numBinsFull;
  final int maxCount;
  final bool isEmpty;

  static _HistogramDiagnostics calculate({
    required List<BarChartSeries> bars,
    required double binWidth,
  }) {
    if (bars.isEmpty) {
      return _HistogramDiagnostics(
        minValue: 0,
        maxValue: 0,
        range: 0,
        numBinsCompact: 0,
        numBinsFull: 0,
        maxCount: 0,
        isEmpty: true,
      );
    }

    final allValues =
        bars.expand((bar) => bar.values).where((v) => v > 0).toList();

    if (allValues.isEmpty) {
      return _HistogramDiagnostics(
        minValue: 0,
        maxValue: 0,
        range: 0,
        numBinsCompact: 0,
        numBinsFull: 0,
        maxCount: 0,
        isEmpty: true,
      );
    }

    final minValue = allValues.reduce((a, b) => a < b ? a : b);
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    final numBinsCompact = (range / binWidth).ceil() + 1;

    final numBinsFull = (maxValue / binWidth).ceil() + 1;

    final barsWithBinWidth =
        bars.map((bar) => bar.copyWith(binWidth: binWidth)).toList();
    final allCounts =
        barsWithBinWidth
            .expand((series) => series.getBarsData().map((data) => data.$2))
            .toList();
    final maxCount =
        allCounts.isEmpty ? 0 : allCounts.reduce((a, b) => a > b ? a : b);

    return _HistogramDiagnostics(
      minValue: minValue,
      maxValue: maxValue,
      range: range,
      numBinsCompact: numBinsCompact,
      numBinsFull: numBinsFull,
      maxCount: maxCount,
      isEmpty: false,
    );
  }
}

class DiameterBarChartComponent extends StatefulWidget {
  const DiameterBarChartComponent({
    super.key,
    required this.bars,
    this.isExportMode = false,
    this.showNavigationArrows = true,
    this.isFullscreenHistogram = false,
    this.showWarnings = true,
    this.onWarningsChanged,
    this.onRecommendedBinWidthChanged,
    this.swapAxes = false,
    this.showLegend = true,
    this.initialBinWidth,
    this.showBinWidthSelector = true,
    this.usePercentages,
    this.onUsePercentagesChanged,
  });

  final List<BarChartSeries> bars;
  final bool isExportMode;
  final bool showNavigationArrows;
  final bool isFullscreenHistogram;
  final bool showWarnings;
  final void Function(String? binWidthWarning, String? yWarning)?
  onWarningsChanged;
  final void Function(double? recommendedBinWidth)?
  onRecommendedBinWidthChanged;
  final bool swapAxes;
  final bool showLegend;
  final double? initialBinWidth;
  final bool showBinWidthSelector;
  final bool? usePercentages;
  final void Function(bool)? onUsePercentagesChanged;

  static Widget createForExport({
    required List<BarChartSeries> bars,
    required double binWidth,
  }) {
    return _ExportChartWidget(bars: bars, binWidth: binWidth);
  }

  @override
  State<DiameterBarChartComponent> createState() =>
      _DiameterBarChartComponentState();
}

class _DiameterBarChartComponentState extends State<DiameterBarChartComponent> {
  double _userSelectedBinWidth = 1.0;
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = false;
  bool _showNavigationArrows = true;
  bool _isExportMode = false;
  bool _hasScrolledToFirstValue = false;
  String? _binWidthWarning;
  String? _yAutoAdjustMessage;
  bool _hasAutoAppliedRecommendedBin = false;
  double? _minBinWidthForVertical;
  double? _minBinWidthForHorizontal;
  Orientation? _lastOrientation;
  bool _internalUsePercentages = true;
  
  bool get _usePercentages => widget.usePercentages ?? _internalUsePercentages;
  
  void _setUsePercentages(bool value) {
    if (widget.onUsePercentagesChanged != null) {
      widget.onUsePercentagesChanged!(value);
    } else {
      setState(() {
        _internalUsePercentages = value;
      });
    }
  }

  final List<double> _binWidthOptions = [1.0, 3.0, 5.0, 10.0, 15.0, 20.0];
  static const int _maxBinsAllowed = 18;

  double? _getRecommendedBinWidth(
    _HistogramDiagnostics diag, {
    double? screenWidth,
    double? screenHeight,
  }) {
    if (diag.isEmpty) return null;

    if (screenHeight != null &&
        widget.isFullscreenHistogram &&
        widget.swapAxes &&
        !widget.isExportMode) {
      for (final binWidth in _binWidthOptions) {
        final testDiag = _HistogramDiagnostics.calculate(
          bars: widget.bars,
          binWidth: binWidth,
        );

        final totalGroups = testDiag.numBinsFull;

        double minHeightPerValue;
        if (binWidth == 1.0) {
          minHeightPerValue = 30.0;
        } else if (binWidth == 3.0) {
          minHeightPerValue = 40.0;
        } else if (binWidth == 5.0) {
          minHeightPerValue = 50.0;
        } else {
          minHeightPerValue = 60.0;
        }

        final calculatedHeight = totalGroups * minHeightPerValue;

        if (calculatedHeight <= screenHeight) {
          return binWidth;
        }
      }
      return _binWidthOptions.last;
    }

    if (screenWidth != null &&
        !widget.isExportMode &&
        !widget.isFullscreenHistogram) {
      for (final binWidth in _binWidthOptions) {
        final testDiag = _HistogramDiagnostics.calculate(
          bars: widget.bars,
          binWidth: binWidth,
        );

        final totalGroups = testDiag.numBinsFull;

        double minWidthPerValue;
        if (binWidth == 1.0) {
          minWidthPerValue = 15.0;
        } else if (binWidth == 3.0) {
          minWidthPerValue = 18.0;
        } else if (binWidth == 5.0) {
          minWidthPerValue = 22.0;
        } else {
          minWidthPerValue = 26.0;
        }

        final calculatedWidth = totalGroups * minWidthPerValue;

        if (calculatedWidth <= screenWidth) {
          return binWidth;
        }
      }
      return _binWidthOptions.last;
    }

    if (diag.numBinsFull <= _maxBinsAllowed) return null;

    for (final binWidth in _binWidthOptions) {
      final testDiag = _HistogramDiagnostics.calculate(
        bars: widget.bars,
        binWidth: binWidth,
      );

      if (testDiag.numBinsFull <= _maxBinsAllowed) {
        return binWidth;
      }
    }

    return _binWidthOptions.last;
  }

  double? _getMinBinWidthForFullscreenVertical() {
    if (widget.bars.isEmpty) return null;

    final orientation = MediaQuery.of(context).orientation;
    final isFullscreenVertical =
        widget.isFullscreenHistogram && orientation == Orientation.portrait;

    if (!isFullscreenVertical) return null;

    final screenWidth = MediaQuery.of(context).size.width;
    final diag = _HistogramDiagnostics.calculate(
      bars: widget.bars,
      binWidth: 1.0,
    );

    if (diag.isEmpty) return null;

    for (final binWidth in _binWidthOptions) {
      final testDiag = _HistogramDiagnostics.calculate(
        bars: widget.bars,
        binWidth: binWidth,
      );

      final totalGroups = testDiag.numBinsFull;

      double minWidthPerValue;
      if (binWidth == 1.0) {
        minWidthPerValue = 15.0;
      } else if (binWidth == 3.0) {
        minWidthPerValue = 18.0;
      } else if (binWidth == 5.0) {
        minWidthPerValue = 20.0;
      } else {
        minWidthPerValue = 25.0;
      }

      final calculatedWidth = totalGroups * minWidthPerValue;

      if (calculatedWidth <= screenWidth) {
        return binWidth;
      }
    }
    return _binWidthOptions.last;
  }

  double? _getMinBinWidthForFullscreenHorizontal() {
    if (widget.bars.isEmpty) return null;

    final orientation = MediaQuery.of(context).orientation;
    final isFullscreenHorizontal =
        widget.isFullscreenHistogram && orientation == Orientation.landscape;

    if (!isFullscreenHorizontal) return null;

    final screenWidth = MediaQuery.of(context).size.width;
    final diag = _HistogramDiagnostics.calculate(
      bars: widget.bars,
      binWidth: 1.0,
    );

    if (diag.isEmpty) return null;

    for (final binWidth in _binWidthOptions) {
      final testDiag = _HistogramDiagnostics.calculate(
        bars: widget.bars,
        binWidth: binWidth,
      );

      final totalGroups = testDiag.numBinsFull;

      double minWidthPerValue;
      if (binWidth == 1.0) {
        minWidthPerValue = 20.0;
      } else if (binWidth == 3.0) {
        minWidthPerValue = 25.0;
      } else if (binWidth == 5.0) {
        minWidthPerValue = 30.0;
      } else {
        minWidthPerValue = 35.0;
      }

      final calculatedWidth = totalGroups * minWidthPerValue;

      if (calculatedWidth <= screenWidth) {
        return binWidth;
      }
    }
    return _binWidthOptions.last;
  }

  void _calculateAndSetMinBinWidth() {
    final verticalMin = _getMinBinWidthForFullscreenVertical();
    final horizontalMin = _getMinBinWidthForFullscreenHorizontal();

    setState(() {
      _minBinWidthForVertical = verticalMin;
      _minBinWidthForHorizontal = horizontalMin;

      // Ajustar automáticamente si el binWidth actual es menor al mínimo correspondiente
      final orientation = MediaQuery.of(context).orientation;
      final isFullscreenVertical =
          widget.isFullscreenHistogram && orientation == Orientation.portrait;
      final isFullscreenHorizontal =
          widget.isFullscreenHistogram && orientation == Orientation.landscape;

      if (isFullscreenVertical &&
          verticalMin != null &&
          _userSelectedBinWidth < verticalMin) {
        _userSelectedBinWidth = verticalMin;
      } else if (isFullscreenHorizontal &&
          horizontalMin != null &&
          _userSelectedBinWidth < horizontalMin) {
        _userSelectedBinWidth = horizontalMin;
      }
    });
  }

  void setExportMode(bool isExport) {
    if (mounted) {
      setState(() {
        _isExportMode = isExport;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialBinWidth != null) {
      _userSelectedBinWidth = widget.initialBinWidth!;
    }
    _scrollController.addListener(_updateArrowsVisibility);
    chartArrowVisibilityNotifier.addListener(_onArrowVisibilityChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      _updateArrowsVisibility();
      if (!widget.swapAxes) {
        _scrollToFirstNonZeroValue(_userSelectedBinWidth);
      }
      _calculateAndSetMinBinWidth();
    });
  }

  void _onArrowVisibilityChanged() {
    setState(() {
      _showNavigationArrows = chartArrowVisibilityNotifier.value;
    });
  }

  @override
  void didUpdateWidget(DiameterBarChartComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialBinWidth != null &&
        widget.initialBinWidth != oldWidget.initialBinWidth) {
      setState(() {
        _userSelectedBinWidth = widget.initialBinWidth!;
      });
    }

    if (widget.bars != oldWidget.bars ||
        widget.isFullscreenHistogram != oldWidget.isFullscreenHistogram) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _calculateAndSetMinBinWidth();
        }
      });
    }

    if (widget.swapAxes != oldWidget.swapAxes) {
      _hasScrolledToFirstValue = false;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
        _updateArrowsVisibility();
        if (!widget.swapAxes) {
          _scrollToFirstNonZeroValue(_userSelectedBinWidth);
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && mounted) {
            debugPrint('📊 Ejecutando ajuste de scroll (postFrameCallback)');
            _scrollController.jumpTo(0);
            _updateArrowsVisibility();
            if (!widget.swapAxes) {
              _scrollToFirstNonZeroValue(_userSelectedBinWidth);
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrowsVisibility);
    chartArrowVisibilityNotifier.removeListener(_onArrowVisibilityChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrowsVisibility() {
    if (!mounted || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    setState(() {
      _showLeftArrow = _scrollController.offset > 10;
      _showRightArrow =
          position.maxScrollExtent > 0 &&
          _scrollController.offset < position.maxScrollExtent - 10;
    });
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    _scrollController
        .animateTo(
          math.max(0, _scrollController.offset - 200),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .then((_) => _updateArrowsVisibility());
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    _scrollController
        .animateTo(
          math.min(
            _scrollController.position.maxScrollExtent,
            _scrollController.offset + 200,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .then((_) => _updateArrowsVisibility());
  }

  void _scrollToFirstNonZeroValue(double effectiveBinWidth) {
    if (!_scrollController.hasClients ||
        _hasScrolledToFirstValue ||
        _isExportMode) {
      return;
    }

    final barsWithBinWidth =
        widget.bars
            .map((bar) => bar.copyWith(binWidth: effectiveBinWidth))
            .toList();

    if (barsWithBinWidth.isEmpty) return;

    final allValues =
        widget.bars.expand((bar) => bar.values).where((v) => v > 0).toList();

    if (allValues.isEmpty) {
      _hasScrolledToFirstValue = true;
      return;
    }

    final minValue = allValues.reduce((a, b) => a < b ? a : b);
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);

    const minBin = 0;
    final maxBin = (maxValue / effectiveBinWidth).ceil();
    final totalGroups = maxBin - minBin + 1;

    final firstValueBin = (minValue / effectiveBinWidth).floor();

    final relativeIndex = firstValueBin - minBin;

    debugPrint(
      '📊 Chart autoscroll: minValue=$minValue, maxValue=$maxValue, minBin=$minBin, maxBin=$maxBin, totalGroups=$totalGroups',
    );
    debugPrint(
      '📊 Chart autoscroll: firstValueBin=$firstValueBin (absolute), relativeIndex=$relativeIndex (relative)',
    );

    if (relativeIndex <= 1) {
      debugPrint(
        '📊 Chart autoscroll: First value near start of chart, no scroll needed',
      );
      _hasScrolledToFirstValue = true;
      return;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients || !mounted) return;

      final position = _scrollController.position;
      final maxScrollExtent = position.maxScrollExtent;
      final viewportDimension = position.viewportDimension;
      final totalScrollableWidth = maxScrollExtent + viewportDimension;

      final groupWidth = totalScrollableWidth / totalGroups;

      debugPrint(
        '📊 Chart autoscroll: maxScrollExtent=$maxScrollExtent, viewportDimension=$viewportDimension',
      );
      debugPrint(
        '📊 Chart autoscroll: totalScrollableWidth=$totalScrollableWidth, groupWidth=$groupWidth',
      );

      final targetOffset = math.max(0, (relativeIndex - 2) * groupWidth);

      final clampedOffset = targetOffset.clamp(0.0, maxScrollExtent);

      debugPrint(
        '📊 Chart autoscroll: targetOffset=$targetOffset, clampedOffset=$clampedOffset',
      );

      if (_scrollController.hasClients && mounted) {
        debugPrint('📊 Chart autoscroll: Scrolling to $clampedOffset');
        _scrollController
            .animateTo(
              clampedOffset.toDouble(),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            )
            .then((_) {
              _hasScrolledToFirstValue = true;
              _updateArrowsVisibility();
              debugPrint('📊 Chart autoscroll: Scroll completed');
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isExportMode = _isExportMode || widget.isExportMode;
    final orientation = MediaQuery.of(context).orientation;

    if (widget.isFullscreenHistogram &&
        _lastOrientation != null &&
        _lastOrientation != orientation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _calculateAndSetMinBinWidth();
        }
      });
    }
    _lastOrientation = orientation;

    final diag = _HistogramDiagnostics.calculate(
      bars: widget.bars,
      binWidth: _userSelectedBinWidth,
    );

    if (widget.isFullscreenHistogram &&
        widget.swapAxes &&
        !_hasAutoAppliedRecommendedBin &&
        _userSelectedBinWidth == 1.0 &&
        diag.numBinsFull > _maxBinsAllowed) {
      final screenHeight = MediaQuery.of(context).size.height;
      final recommended = _getRecommendedBinWidth(
        diag,
        screenHeight: screenHeight,
      );
      if (recommended != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _userSelectedBinWidth = recommended;
              _hasAutoAppliedRecommendedBin = true;
            });
          }
        });
      }
    }

    _updateWarnings(loc, diag);

    return Column(
      children: [
        if (widget.showWarnings && _binWidthWarning != null)
          Container(
            margin: EdgeInsets.only(bottom: isExportMode ? 4 : 8),
            padding: EdgeInsets.symmetric(
              horizontal: isExportMode ? 8 : 12,
              vertical: isExportMode ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: isExportMode ? 14 : 16,
                  color: Colors.orange.shade700,
                ),
                SizedBox(width: isExportMode ? 6 : 8),
                Expanded(
                  child: Text(
                    _binWidthWarning!,
                    style: TextStyle(
                      fontSize: isExportMode ? 9 : 11,
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (widget.showWarnings && _yAutoAdjustMessage != null)
          Container(
            margin: EdgeInsets.only(bottom: isExportMode ? 4 : 8),
            padding: EdgeInsets.symmetric(
              horizontal: isExportMode ? 8 : 12,
              vertical: isExportMode ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: isExportMode ? 14 : 16,
                  color: Colors.blue.shade700,
                ),
                SizedBox(width: isExportMode ? 6 : 8),
                Expanded(
                  child: Text(
                    _yAutoAdjustMessage!,
                    style: TextStyle(
                      fontSize: isExportMode ? 9 : 11,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.only(bottom: isExportMode ? 4.0 : 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.showLegend && widget.bars.length > 1)
                Flexible(child: _buildLegend(context, isExportMode)),
              if (widget.bars.length <= 1 || !widget.showLegend) const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showBinWidthSelector) ...[
                    Text(
                      '${loc.binWidthGrouping}:',
                      style: TextStyle(
                        fontSize: isExportMode ? 9 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: isExportMode ? 4 : 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isExportMode ? 4 : 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<double>(
                          value: _userSelectedBinWidth,
                          isDense: true,
                          items: () {
                            final orientation =
                                MediaQuery.of(context).orientation;
                            final isFullscreenVertical =
                                widget.isFullscreenHistogram &&
                                orientation == Orientation.portrait;
                            final isFullscreenHorizontal =
                                widget.isFullscreenHistogram &&
                                orientation == Orientation.landscape;

                            List<double> availableOptions = _binWidthOptions;

                            if (isFullscreenVertical &&
                                _minBinWidthForVertical != null) {
                              availableOptions =
                                  _binWidthOptions
                                      .where(
                                        (width) =>
                                            width >= _minBinWidthForVertical!,
                                      )
                                      .toList();
                            } else if (isFullscreenHorizontal &&
                                _minBinWidthForHorizontal != null) {
                              availableOptions =
                                  _binWidthOptions
                                      .where(
                                        (width) =>
                                            width >= _minBinWidthForHorizontal!,
                                      )
                                      .toList();
                            }

                            return availableOptions.map((width) {
                              return DropdownMenuItem<double>(
                                value: width,
                                child: Text(
                                  '${width.toInt()}mm',
                                  style: TextStyle(
                                    fontSize: isExportMode ? 9 : 12,
                                  ),
                                ),
                              );
                            }).toList();
                          }(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _userSelectedBinWidth = value;
                                _hasScrolledToFirstValue = false;
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                if (_scrollController.hasClients) {
                                  _scrollController.jumpTo(0);
                                }
                                // No hacer autoscroll cuando los ejes están invertidos
                                if (!widget.swapAxes) {
                                  _scrollToFirstNonZeroValue(value);
                                }
                                _updateArrowsVisibility();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: isExportMode ? 6 : 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: isExportMode ? null : () => _setUsePercentages(true),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isExportMode ? 6 : 8,
                                vertical: isExportMode ? 2 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: _usePercentages ? Colors.blue.shade100 : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(5),
                                ),
                              ),
                              child: Text(
                                '%',
                                style: TextStyle(
                                  fontSize: isExportMode ? 9 : 11,
                                  fontWeight: _usePercentages ? FontWeight.w600 : FontWeight.w400,
                                  color: _usePercentages ? Colors.blue.shade700 : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: isExportMode ? 14 : 18,
                            color: Colors.grey.shade300,
                          ),
                          GestureDetector(
                            onTap: isExportMode ? null : () => _setUsePercentages(false),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isExportMode ? 6 : 8,
                                vertical: isExportMode ? 2 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: !_usePercentages ? Colors.blue.shade100 : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(5),
                                ),
                              ),
                              child: Text(
                                'Nº',
                                style: TextStyle(
                                  fontSize: isExportMode ? 9 : 11,
                                  fontWeight: !_usePercentages ? FontWeight.w600 : FontWeight.w400,
                                  color: !_usePercentages ? Colors.blue.shade700 : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (isExportMode)
          Expanded(
            child: _buildChart(
              isExportMode: true,
              binWidth: _userSelectedBinWidth,
            ),
          ),
        if (!isExportMode)
          Expanded(
            child:
                (widget.showNavigationArrows && _showNavigationArrows)
                    ? Row(
                      children: [
                        Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_rounded,
                              color:
                                  _showLeftArrow
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                              size: 24,
                            ),
                            onPressed: _showLeftArrow ? _scrollLeft : null,
                            tooltip: loc.tooltipViewPreviousValues,
                          ),
                        ),
                        Expanded(
                          child: _buildChart(binWidth: _userSelectedBinWidth),
                        ),
                        Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color:
                                  _showRightArrow
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                              size: 24,
                            ),
                            onPressed: _showRightArrow ? _scrollRight : null,
                            tooltip: loc.tooltipViewNextValues,
                          ),
                        ),
                      ],
                    )
                    : _buildChart(binWidth: _userSelectedBinWidth),
          ),
      ],
    );
  }

  void _updateWarnings(AppLocalizations loc, _HistogramDiagnostics diag) {
    String? binWidthWarning;
    String? yWarning;

    if (!diag.isEmpty && diag.numBinsFull > _maxBinsAllowed) {
      final recommended = _getRecommendedBinWidth(diag);
      if (recommended != null) {
        if (widget.isFullscreenHistogram) {
          binWidthWarning = loc.binWidthWarningFullscreen(
            _userSelectedBinWidth.toInt(),
            diag.numBinsFull,
            recommended.toInt(),
          );
        } else {
          binWidthWarning = loc.binWidthWarningExport(
            _userSelectedBinWidth.toInt(),
            diag.numBinsFull,
            recommended.toInt(),
          );
        }
      }
    }

    if (!diag.isEmpty && diag.maxCount > 0) {
      final yTicks = calculateYTicks(
        diag.maxCount,
        maxTicks: widget.isFullscreenHistogram ? 5 : null,
      );
      if (yTicks.length >= 2) {
        final step = yTicks[1] - yTicks[0];
        final threshold = widget.isFullscreenHistogram ? 150 : 100;
        if (step >= threshold) {
          yWarning =
              widget.isFullscreenHistogram
                  ? loc.yAxisWarningFullscreen(step)
                  : loc.yAxisWarningNormal(step);
        }
      }
    }

    double? recommendedForCompact;
    if (!widget.isExportMode &&
        !widget.isFullscreenHistogram &&
        !diag.isEmpty) {
      final screenWidth = MediaQuery.of(context).size.width;

      final totalGroups = diag.numBinsFull;
      double minWidthPerValue;
      if (_userSelectedBinWidth == 1.0) {
        minWidthPerValue = 22.0;
      } else if (_userSelectedBinWidth == 3.0) {
        minWidthPerValue = 28.0;
      } else if (_userSelectedBinWidth == 5.0) {
        minWidthPerValue = 34.0;
      } else {
        minWidthPerValue = 40.0;
      }
      final calculatedWidth = totalGroups * minWidthPerValue;

      if (calculatedWidth <= screenWidth) {
        recommendedForCompact = _getRecommendedBinWidth(
          diag,
          screenWidth: screenWidth,
        );
      } else {
        recommendedForCompact = null;
      }
    }

    double? recommendedForFullscreenHorizontal;
    if (widget.isFullscreenHistogram &&
        widget.swapAxes &&
        !widget.isExportMode &&
        !diag.isEmpty) {
      final screenHeight = MediaQuery.of(context).size.height;

      final totalGroups = diag.numBinsFull;
      double minHeightPerValue;
      if (_userSelectedBinWidth == 1.0) {
        minHeightPerValue = 30.0;
      } else if (_userSelectedBinWidth == 3.0) {
        minHeightPerValue = 40.0;
      } else if (_userSelectedBinWidth == 5.0) {
        minHeightPerValue = 50.0;
      } else {
        minHeightPerValue = 60.0;
      }
      final calculatedHeight = totalGroups * minHeightPerValue;

      if (calculatedHeight <= screenHeight) {
        recommendedForFullscreenHorizontal = _getRecommendedBinWidth(
          diag,
          screenHeight: screenHeight,
        );
      } else {
        recommendedForFullscreenHorizontal = null;
      }
    }

    if (binWidthWarning != _binWidthWarning ||
        yWarning != _yAutoAdjustMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _binWidthWarning = binWidthWarning;
            _yAutoAdjustMessage = yWarning;
          });
          if (widget.onWarningsChanged != null) {
            widget.onWarningsChanged!(_binWidthWarning, _yAutoAdjustMessage);
          }
        }
      });
    }

    if (widget.onRecommendedBinWidthChanged != null) {
      final recommended =
          recommendedForFullscreenHorizontal ?? recommendedForCompact;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onRecommendedBinWidthChanged!(recommended);
        }
      });
    }
  }

  Widget _buildLegend(BuildContext context, bool isExportMode) {
    return Wrap(
      spacing: isExportMode ? 8 : 12,
      runSpacing: isExportMode ? 2 : 4,
      children: List.generate(widget.bars.length, (index) {
        final bar = widget.bars[index];
        final color = getColorByIndex(index);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isExportMode ? 12 : 16,
              height: isExportMode ? 12 : 16,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: color.withValues(alpha: 0.7),
                  width: 1,
                ),
              ),
            ),
            SizedBox(width: isExportMode ? 4 : 6),
            Flexible(
              child: Text(
                bar.groupName,
                style: TextStyle(
                  fontSize: isExportMode ? 8 : 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildChart({bool isExportMode = false, required double binWidth}) {
    if (widget.bars.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      return Center(
        child: Text(
          loc.withoutData,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final diag = _HistogramDiagnostics.calculate(
      bars: widget.bars,
      binWidth: binWidth,
    );

    if (diag.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      return Center(
        child: Text(
          loc.withoutData,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final barsWithBinWidth =
        widget.bars.map((bar) => bar.copyWith(binWidth: binWidth)).toList();

    final totalGroups = diag.numBinsFull;
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    final isFullscreenVertical =
        widget.isFullscreenHistogram && orientation == Orientation.portrait;
    final isFullscreenHorizontal =
        widget.isFullscreenHistogram && orientation == Orientation.landscape;

    double minWidthPerValue;
    if (isExportMode) {
      if (binWidth == 1.0) {
        minWidthPerValue = 100.0;
      } else if (binWidth == 3.0) {
        minWidthPerValue = 110.0;
      } else if (binWidth == 5.0) {
        minWidthPerValue = 120.0;
      } else {
        minWidthPerValue = 130.0;
      }
    } else if (isFullscreenVertical || isFullscreenHorizontal) {
      if (isFullscreenHorizontal) {
        if (binWidth == 1.0) {
          minWidthPerValue = 20.0;
        } else if (binWidth == 3.0) {
          minWidthPerValue = 25.0;
        } else if (binWidth == 5.0) {
          minWidthPerValue = 30.0;
        } else {
          minWidthPerValue = 35.0;
        }
      } else {
        if (binWidth == 1.0) {
          minWidthPerValue = 15.0;
        } else if (binWidth == 3.0) {
          minWidthPerValue = 18.0;
        } else if (binWidth == 5.0) {
          minWidthPerValue = 20.0;
        } else {
          minWidthPerValue = 25.0;
        }
      }
    } else {
      if (binWidth == 1.0) {
        minWidthPerValue = 35.0;
      } else if (binWidth == 3.0) {
        minWidthPerValue = 45.0;
      } else if (binWidth == 5.0) {
        minWidthPerValue = 55.0;
      } else {
        minWidthPerValue = 65.0;
      }
    }

    final calculatedWidth = totalGroups * minWidthPerValue;

    final chartWidth =
        (isFullscreenVertical || isFullscreenHorizontal)
            ? screenWidth
            : (isExportMode
                ? calculatedWidth
                : (calculatedWidth > screenWidth
                    ? calculatedWidth
                    : screenWidth));

    final chartContent = SizedBox(
      width: chartWidth,
      height: double.infinity,
      child: CustomGroupedBarChart(
        series: barsWithBinWidth,
        binWidth: binWidth,
        isExportMode: isExportMode,
        isFullscreenHistogram: widget.isFullscreenHistogram,
        swapAxes: widget.swapAxes,
        usePercentages: _usePercentages,
        disableInteractions: _isExportMode,
      ),
    );

    if (isExportMode) {
      return chartContent;
    }

    if (isFullscreenVertical || isFullscreenHorizontal) {
      return chartContent;
    }

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: chartContent,
    );
  }
}

class _ExportChartWidget extends StatelessWidget {
  const _ExportChartWidget({required this.bars, required this.binWidth});

  final List<BarChartSeries> bars;
  final double binWidth;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      return Center(
        child: Text(
          loc.withoutData,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final diag = _HistogramDiagnostics.calculate(
      bars: bars,
      binWidth: binWidth,
    );

    if (diag.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      return Center(
        child: Text(
          loc.withoutData,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final barsWithBinWidth =
        bars.map((bar) => bar.copyWith(binWidth: binWidth)).toList();

    final totalGroups = diag.numBinsFull;

    double minWidthPerValue;
    if (binWidth == 1.0) {
      minWidthPerValue = 35.0;
    } else if (binWidth == 3.0) {
      minWidthPerValue = 45.0;
    } else if (binWidth == 5.0) {
      minWidthPerValue = 55.0;
    } else {
      minWidthPerValue = 65.0;
    }

    final calculatedWidth = totalGroups * minWidthPerValue;

    return SizedBox(
      width: calculatedWidth,
      height: 240,
      child: CustomGroupedBarChart(
        series: barsWithBinWidth,
        binWidth: binWidth,
        isExportMode: true,
        usePercentages: true,
        disableInteractions: true,
      ),
    );
  }
}
