import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/domains/charts/models/chart_type_enum.dart';
import 'package:fruit_measure_app/domains/charts/views/diameter_chart_component.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/services/download_csv_file.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareChartButton extends StatefulWidget {
  const ShareChartButton({
    super.key,
    this.repaintKey,
    this.chartComponentKey,
    required this.textToExport,
    required this.chartType,
    this.onCaptureStart,
    this.onCaptureEnd,
  });

  final GlobalKey? repaintKey;

  final GlobalKey? chartComponentKey;

  final List<String> textToExport;

  final ChartType chartType;

  final VoidCallback? onCaptureStart;

  final VoidCallback? onCaptureEnd;

  @override
  State<ShareChartButton> createState() => _ShareChartButtonState();
}

class _ShareChartButtonState extends State<ShareChartButton>
    with UpdateState<ShareChartButton> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const SizedBox.shrink();
    }

    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        }
      });
      return const SizedBox.shrink();
    }

    return SpeedDial(
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      heroTag: 'SpeedDialRight',
      spaceBetweenChildren: 5,
      spacing: 10,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.photo_camera),
          label: loc.shareChartImage,
          elevation: 2,
          onTap: () async {
            try {
              widget.onCaptureStart?.call();
              chartArrowVisibilityNotifier.value = false;

              final chartComponent = widget.chartComponentKey?.currentState;
              if (chartComponent is State) {
                try {
                  (chartComponent as dynamic).setExportMode(true);
                } catch (e) {}
              }

              for (int i = 0; i < 5; i++) {
                final completer = Completer<void>();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  completer.complete();
                });
                await completer.future;
              }

              final boundary =
                  widget.repaintKey?.currentContext?.findRenderObject()
                      as RenderRepaintBoundary?;

              if (boundary != null) {
                final image = await boundary.toImage(pixelRatio: 3.0);
                final byteData = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                if (byteData == null) throw Exception('No byteData');

                final pngBytes = byteData.buffer.asUint8List();

                final tempDir = await getTemporaryDirectory();
                final file = File('${tempDir.path}/chart_image.png');
                await file.writeAsBytes(pngBytes);

                final params = ShareParams(files: [XFile(file.path)]);

                final result = await SharePlus.instance.share(params);

                result.status.name == 'success'
                    ? customSnackBar(
                      context: context,
                      message: loc.actionDone,
                      type: SnackbarType.success,
                    )
                    : null;
              }
            } catch (e) {
              customSnackBar(
                context: context,
                message: loc.actionNotDone,
                type: SnackbarType.error,
              );
            } finally {
              final chartComponent = widget.chartComponentKey?.currentState;
              if (chartComponent is State) {
                try {
                  (chartComponent as dynamic).setExportMode(false);
                } catch (e) {}
              }
              chartArrowVisibilityNotifier.value = true;
              widget.onCaptureEnd?.call();
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.arrow_upward),
          label: loc.shareChartCsv,
          elevation: 2,
          onTap: () async {
            try {
              final result = await downloadCsvFile(
                fileName: widget.chartType.toFileName(),
                csvHeader: widget.chartType.toCsvHeader(),
                textValues: widget.textToExport.join('\n'),
              );

              result.status.name == 'success'
                  ? (customSnackBar(
                    context: context,
                    message: loc.actionDone,
                    type: SnackbarType.success,
                  ))
                  : null;
            } catch (e) {
              customSnackBar(
                context: context,
                message: loc.actionNotDone,
                type: SnackbarType.error,
              );
            }
          },
        ),
      ],
      child: const Icon(Icons.ios_share),
    );
  }
}
