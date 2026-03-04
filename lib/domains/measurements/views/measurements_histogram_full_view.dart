import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruit_measure_app/domains/charts/models/bar_chart_series.dart';
import 'package:fruit_measure_app/domains/charts/views/diameter_chart_component.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';

const fmaAppBarBlack = Color(0xFF1E1E1E);
const fmaAppBarWhite = Color(0xFFF1F3F4);

class MeasurementsHistogramFullView extends StatefulWidget {
  const MeasurementsHistogramFullView({
    super.key,
    required this.bars,
    required this.originalOrientations,
  });

  final List<BarChartSeries> bars;
  final List<DeviceOrientation> originalOrientations;

  @override
  State<MeasurementsHistogramFullView> createState() =>
      _MeasurementsHistogramFullViewState();
}

class _MeasurementsHistogramFullViewState
    extends State<MeasurementsHistogramFullView> {
  bool _isLandscape = false;
  bool _hasInitializedOrientation = false;
  bool _isToggling = false; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitializedOrientation) {
      final orientation = MediaQuery.of(context).orientation;
      _isLandscape = orientation == Orientation.landscape;
      _hasInitializedOrientation = true;
    }
  }

  void _toggleOrientation() {
    _isToggling = true;
    setState(() {
      _isLandscape = !_isLandscape;
    });

    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isToggling = false;
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(widget.originalOrientations);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    
   
    if (_hasInitializedOrientation && !_isToggling) {
      final expectedLandscape = orientation == Orientation.landscape;
      if (_isLandscape != expectedLandscape) {
        _isLandscape = expectedLandscape;
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: fmaAppBarWhite,
        title: Text(
          loc.caliber,
          style: const TextStyle(
            color: fmaAppBarBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.screen_rotation, color: fmaAppBarBlack),
            tooltip: loc.tooltipRotateScreen,
            onPressed: _toggleOrientation,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: fmaAppBarBlack),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              widget.bars.isNotEmpty
                  ? Column(
                    children: [
                      if (isPortrait)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  loc.invertedAxesMessage,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isPortrait) const SizedBox(height: 12),
                      Expanded(
                        child: DiameterBarChartComponent(
                          bars: widget.bars,
                          isFullscreenHistogram: true,
                          showWarnings: false,
                          showLegend: true,
                          swapAxes: isPortrait,
                          initialBinWidth: null,
                          showBinWidthSelector: true,
                          showNavigationArrows: false,
                          onWarningsChanged: null,
                          onRecommendedBinWidthChanged: null,
                        ),
                      ),
                    ],
                  )
                  : Center(
                    child: Text(
                      loc.withoutData,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
        ),
      ),
    );
  }
}
