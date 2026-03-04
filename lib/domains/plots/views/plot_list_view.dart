import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fruit_measure_app/components/colors.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/components/empty_list_component.dart';
import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement_complete.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurement_list_view.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurements_multi_growth_curve_stadistics_view.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/services/recover_photo_from_gallery.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/plots/models/plot_options_actions.dart';
import 'package:fruit_measure_app/domains/plots/models/types_plot_options_actions.dart';
import 'package:fruit_measure_app/domains/plots/services/export_plots.dart';
import 'package:fruit_measure_app/domains/plots/services/export_plots_to_kml.dart';
import 'package:fruit_measure_app/domains/plots/services/import_plots.dart';
import 'package:fruit_measure_app/domains/plots/views/plot_view.dart';
import 'package:fruit_measure_app/domains/plots/views/plots_map_view.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:uuid/uuid.dart';

class PlotListView extends StatefulWidget {
  const PlotListView({super.key});

  @override
  State<PlotListView> createState() => _PlotListViewState();
}

class _PlotListViewState extends State<PlotListView>
    with UpdateState<PlotListView> {
  final plotListOptions = PlotOptionsActions(
    plots: [],
    type: TypesPlotOptionsActions.defaultView,
  );

  String searchQuery = '';

  List<Plot>? _cachedPlots;
  String? _lastSearchQuery;
  int? _lastPlotsCount;
  String? _lastUserId;
  int? _lastModificationDateSum;

  List<Plot> get _plots {
    if (currentUser == null) {
      _cachedPlots = null;
      _lastUserId = null;
      _lastModificationDateSum = null;
      return [];
    }

    final plotBox = Hive.box<Plot>(plotBoxName);

    final allPlots =
        plotBox.values.where((plot) => plot.userId == currentUser!.id).toList();

    final currentCount = allPlots.length;
    final currentUserId = currentUser!.id;

    final currentModificationDateSum =
        allPlots.isEmpty
            ? null
            : allPlots
                .map((plot) => plot.modificationDate.millisecondsSinceEpoch)
                .fold<int>(0, (sum, ms) => sum + ms);

    if (_cachedPlots != null &&
        _lastSearchQuery == searchQuery &&
        _lastPlotsCount == currentCount &&
        _lastUserId == currentUserId &&
        _lastModificationDateSum == currentModificationDateSum) {
      return _cachedPlots!;
    }

    _lastSearchQuery = searchQuery;
    _lastPlotsCount = currentCount;
    _lastUserId = currentUserId;
    _lastModificationDateSum = currentModificationDateSum;

    _cachedPlots =
        allPlots
            .where(
              (plot) => plot.searchField.toLowerCase().contains(searchQuery),
            )
            .sortedByDescending((e) => e.creationDate)
            .toList();

    return _cachedPlots!;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No hay usuario autenticado')),
      );
    }

    final List<Plot> plots = _plots;

    return Scaffold(
      appBar: CustomAppBar(title: loc.plots),
      endDrawer: const AccountEndDrawer(),
      drawerBarrierDismissible: false,
      endDrawerEnableOpenDragGesture: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.plots,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: loc.searchPlots,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.tertiary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery = value.toLowerCase();
                      updateState();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  plots.isNotEmpty
                      ? ListView.builder(
                        itemCount: plots.length,
                        itemBuilder: (context, index) {
                          final plot = plots[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            leading: plotListOptions.getRadioValues(
                              context: context,
                              plot: plot,
                              updateState: updateState,
                            ),
                            title: Text(
                              plot.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              [
                                plot.farmer,
                                plot.variety,
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(plot.plantationDate),
                              ].where((e) => e.isNotEmpty).join(', '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing:
                                (plotListOptions.type !=
                                        TypesPlotOptionsActions.defaultView)
                                    ? null
                                    : const Icon(Icons.chevron_right),
                            onTap: () {
                              plotListOptions.onTap(
                                context: context,
                                updateState: updateState,
                                plot: plot,
                              );
                            },
                          );
                        },
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EmptyListComponent(
                            icon: Icons.map,
                            title: loc.withoutPlots,
                            description: loc.noPlotsRegistered,
                          ),
                        ],
                      ),
            ),
            if (plotListOptions.type != TypesPlotOptionsActions.defaultView)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnRedLight,
                        ),
                        onPressed: () {
                          plotListOptions.changeType(
                            newType: TypesPlotOptionsActions.defaultView,
                            updateState: updateState,
                          );
                        },
                        child: Text(
                          loc.cancel,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnRedDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnGreenLight,
                        ),
                        onPressed:
                            plotListOptions.plots.isEmpty &&
                                    plotListOptions.selectedForDuplicate == null
                                ? null
                                : () async {
                                  if (plotListOptions.type ==
                                          TypesPlotOptionsActions.duplicate &&
                                      plotListOptions.selectedForDuplicate !=
                                          null) {
                                    try {
                                      // Load complete plot with all measurements, photos, and detections
                                      final originalPlotComplete =
                                          await loadCompletePlot(
                                            plot:
                                                plotListOptions
                                                    .selectedForDuplicate!,
                                            updateGalleryPaths: false,
                                          );

                                      // Create new plot with new UUID
                                      final duplicatedPlot = Plot(
                                        id: const Uuid().v4(),
                                        name:
                                            '${originalPlotComplete.name} (${loc.copy})',
                                        userId: originalPlotComplete.userId,
                                        description:
                                            originalPlotComplete.description,
                                        farmer: originalPlotComplete.farmer,
                                        creationDate: DateTime.now(),
                                        modificationDate: DateTime.now(),
                                        plantationDate:
                                            originalPlotComplete.plantationDate,
                                        variety: originalPlotComplete.variety,
                                        lat: originalPlotComplete.lat,
                                        lng: originalPlotComplete.lng,
                                      );

                                      // Save the duplicated plot
                                      final plotBox = Hive.box<Plot>(
                                        plotBoxName,
                                      );
                                      await plotBox.put(
                                        duplicatedPlot.id,
                                        duplicatedPlot,
                                      );

                                      // Duplicate measurements, photos, and detections
                                      final measurementBox =
                                          Hive.box<Measurement>(
                                            measurementBoxName,
                                          );
                                      final photoBox = Hive.box<Photo>(
                                        photoBoxName,
                                      );
                                      final detectionsBox = Hive.box<Detection>(
                                        detectionsBoxName,
                                      );

                                      // Duplicate measurements
                                      for (final originalMeasurement
                                          in originalPlotComplete
                                              .measurements) {
                                        final newMeasurementId =
                                            const Uuid().v4();

                                        final duplicatedMeasurement =
                                            Measurement(
                                              id: newMeasurementId,
                                              plotId: duplicatedPlot.id,
                                              model: originalMeasurement.model,
                                              name: originalMeasurement.name,
                                              observations:
                                                  originalMeasurement
                                                      .observations,
                                              creationDate:
                                                  originalMeasurement
                                                      .creationDate,
                                              modificationDate:
                                                  originalMeasurement
                                                      .modificationDate,
                                            );

                                        await measurementBox.put(
                                          duplicatedMeasurement.id,
                                          duplicatedMeasurement,
                                        );

                                        // Duplicate photos for this measurement
                                        for (final originalPhoto
                                            in originalMeasurement.photos) {
                                          final newPhotoId = const Uuid().v4();

                                          final duplicatedPhoto = Photo(
                                            id: newPhotoId,
                                            measurementId: newMeasurementId,
                                            captureDate:
                                                originalPhoto.captureDate,
                                            creationDate:
                                                originalPhoto.creationDate,
                                            latitude: originalPhoto.latitude,
                                            longitude: originalPhoto.longitude,
                                            imagePath: originalPhoto.imagePath,
                                            galleryPath:
                                                originalPhoto.galleryPath,
                                            originalImagePath:
                                                originalPhoto.originalImagePath,
                                          );

                                          await photoBox.put(
                                            duplicatedPhoto.id,
                                            duplicatedPhoto,
                                          );

                                          // Duplicate detections for this photo
                                          for (final originalDetection
                                              in originalPhoto.detections) {
                                            final duplicatedDetection =
                                                Detection(
                                                  id: const Uuid().v4(),
                                                  photoId: newPhotoId,
                                                  confidence:
                                                      originalDetection
                                                          .confidence,
                                                  cls: originalDetection.cls,
                                                  x1: originalDetection.x1,
                                                  y1: originalDetection.y1,
                                                  x2: originalDetection.x2,
                                                  y2: originalDetection.y2,
                                                  caliber:
                                                      originalDetection.caliber,
                                                );

                                            await detectionsBox.put(
                                              duplicatedDetection.id,
                                              duplicatedDetection,
                                            );
                                          }
                                        }
                                      }

                                      final arguments = PlotViewArguments(
                                        plot: duplicatedPlot,
                                        isCreatePlot: true,
                                      );
                                      await Navigator.of(context)
                                          .pushNamed(
                                            '/plot',
                                            arguments: arguments,
                                          )
                                          .then((value) {
                                            if (value is Plot) {
                                              final arguments =
                                                  MeasurementListViewArguments(
                                                    plot: value,
                                                  );
                                              Navigator.of(context)
                                                  .pushNamed(
                                                    '/measurements',
                                                    arguments: arguments,
                                                  )
                                                  .then(
                                                    (value) => updateState(),
                                                  );
                                            }
                                            updateState();
                                          });

                                      plotListOptions.changeType(
                                        newType:
                                            TypesPlotOptionsActions.defaultView,
                                        updateState: updateState,
                                      );
                                    } catch (e) {
                                      customSnackBar(
                                        context: context,
                                        message: loc.actionNotDone,
                                        type: SnackbarType.error,
                                      );
                                    }
                                  }

                                  if (plotListOptions.type ==
                                          TypesPlotOptionsActions.export &&
                                      plotListOptions.plots.isNotEmpty) {
                                    try {
                                      final filePath = await exportPlots(
                                        plotListOptions.plots,
                                        loc: AppLocalizations.of(context),
                                      );

                                      if (filePath == null) return;

                                      customSnackBar(
                                        context: context,
                                        message:
                                            AppLocalizations.of(
                                              context,
                                            )!.actionDone,
                                        type: SnackbarType.success,
                                      );
                                    } catch (e) {
                                      final loc = AppLocalizations.of(context)!;
                                      String errorMessage =
                                          loc.errorExportFailed;
                                      if (e.toString().contains(
                                        'EXPORT_ERROR',
                                      )) {
                                        errorMessage = loc.errorExportFailed;
                                      }
                                      customSnackBar(
                                        context: context,
                                        message: errorMessage,
                                        type: SnackbarType.error,
                                      );
                                      return;
                                    }

                                    plotListOptions.changeType(
                                      newType:
                                          TypesPlotOptionsActions.defaultView,
                                      updateState: updateState,
                                    );
                                  }

                                  if (plotListOptions.type ==
                                      TypesPlotOptionsActions.compareCharts) {
                                    final arguments =
                                        MeasurementsMultiGrowthCurveStatisticsViewArguments(
                                          plots: plotListOptions.plots,
                                        );
                                    await Navigator.of(context).pushNamed(
                                      '/measurements-multi-growth-curve-statistics',
                                      arguments: arguments,
                                    );

                                    plotListOptions.changeType(
                                      newType:
                                          TypesPlotOptionsActions.defaultView,
                                      updateState: updateState,
                                    );
                                  }

                                  if (plotListOptions.type ==
                                      TypesPlotOptionsActions.downloadKml) {
                                    final String? outputFile =
                                        await exportPlotsToKml(
                                          plotListOptions.plots,
                                        );

                                    plotListOptions.changeType(
                                      newType:
                                          TypesPlotOptionsActions.defaultView,
                                      updateState: updateState,
                                    );

                                    outputFile != null
                                        ? customSnackBar(
                                          context: context,
                                          message: loc.actionDone,
                                          type: SnackbarType.success,
                                        )
                                        : customSnackBar(
                                          context: context,
                                          message: loc.actionNotDone,
                                          type: SnackbarType.error,
                                        );
                                  }
                                },
                        child: Text(
                          loc.accept,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                plotListOptions.plots.isNotEmpty
                                    ? btnGreenDark
                                    : null,
                            fontWeight: FontWeight.w500,
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
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Stack(
          children: [
            Positioned(
              left: 24,
              bottom: 24,
              child: SpeedDial(
                icon: Icons.map,
                activeIcon: Icons.close,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                heroTag: 'SpeedDialLeft',
                spaceBetweenChildren: 5,
                spacing: 10,
                switchLabelPosition: true,
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.show_chart),
                    label: loc.compareGrowthCurves,
                    elevation: 2,
                    onTap: () {
                      if (plotListOptions.type ==
                          TypesPlotOptionsActions.compareCharts) {
                        plotListOptions.changeType(
                          newType: TypesPlotOptionsActions.defaultView,
                          updateState: updateState,
                        );
                      } else {
                        plotListOptions.changeType(
                          newType: TypesPlotOptionsActions.compareCharts,
                          updateState: updateState,
                        );
                      }
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.map_outlined),
                    label: loc.viewAllPlotsOnMap,
                    elevation: 2,
                    onTap: () {
                      final plotsWithLocation =
                          plots
                              .where((p) => p.lat != null && p.lng != null)
                              .toList();

                      if (plotsWithLocation.isEmpty) {
                        customSnackBar(
                          context: context,
                          message: loc.noPlotsWithLocation,
                          type: SnackbarType.error,
                        );
                      } else {
                        final arguments = PlotsMapViewArguments(
                          plots: plotsWithLocation,
                        );
                        Navigator.of(
                          context,
                        ).pushNamed('/plots-map', arguments: arguments);
                      }
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: SpeedDial(
                icon: Icons.add,
                activeIcon: Icons.close,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                heroTag: 'SpeedDialRight',
                spaceBetweenChildren: 5,
                spacing: 10,
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.add),
                    label: loc.createPlot,
                    elevation: 2,
                    onTap: () {
                      final newPlot = Plot(
                        id: const Uuid().v4(),
                        name: '',
                        userId: currentUser!.id,
                        description: '',
                        farmer: '',
                        creationDate: DateTime.now(),
                        modificationDate: DateTime.now(),
                        plantationDate: DateTime.now(),
                        variety: '',
                        lat: null,
                        lng: null,
                      );

                      final arguments = PlotViewArguments(
                        plot: newPlot,
                        isCreatePlot: true,
                      );
                      Navigator.of(
                        context,
                      ).pushNamed('/plot', arguments: arguments).then((value) {
                        if (value is Plot) {
                          final arguments = MeasurementListViewArguments(
                            plot: value,
                          );
                          Navigator.of(context)
                              .pushNamed('/measurements', arguments: arguments)
                              .then((value) => updateState());
                        }
                        updateState();
                      });
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.file_upload),
                    label: loc.exportPlots,
                    elevation: 2,
                    onTap: () {
                      if (plotListOptions.type ==
                          TypesPlotOptionsActions.export) {
                        plotListOptions.changeType(
                          newType: TypesPlotOptionsActions.defaultView,
                          updateState: updateState,
                        );
                      } else {
                        plotListOptions.changeType(
                          newType: TypesPlotOptionsActions.export,
                          updateState: updateState,
                        );
                      }
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.file_download),
                    label: loc.importPlots,
                    elevation: 2,
                    onTap: () async {
                      try {
                        final ps = await PhotoManager.requestPermissionExtend();

                        final result = await importPlots();

                        if (result.hasError) {
                          if (result.errorType == ImportErrorType.cancelled) {
                            return;
                          }

                          String errorMessage;
                          switch (result.errorMessage) {
                            case 'wrongFileTypeMeasurement':
                              errorMessage =
                                  loc.errorImportWrongFileMeasurement;
                              break;
                            case 'wrongFileTypeGeneric':
                              errorMessage =
                                  loc.errorImportWrongFileGenericPlots;
                              break;
                            case 'emptyFile':
                              errorMessage = loc.errorImportEmptyFile;
                              break;
                            case 'noPlots':
                              errorMessage = loc.errorImportNoPlots;
                              break;
                            case 'parseError':
                              errorMessage = loc.errorImportParseErrorPlots;
                              break;
                            default:
                              errorMessage = loc.actionNotDone;
                          }

                          showErrorDialog(
                            context: context,
                            message: errorMessage,
                          );
                          return;
                        }

                        if (result.plots.isEmpty) {
                          return;
                        }

                        int newPlotsCount = 0;
                        int newPlotsMeasurementsCount = 0;
                        int existingPlotsCount = 0;
                        int restoredMeasurementsCount = 0;

                        final plotBox = Hive.box<Plot>(plotBoxName);
                        final measurementBox = Hive.box<Measurement>(
                          measurementBoxName,
                        );

                        final existingMeasurements =
                            measurementBox.values.toList();

                        _permissionState = ps;

                        for (final plot in result.plots) {
                          final existingPlot = plots.firstWhereOrNull(
                            (p) => p.sourceId == plot.id,
                          );

                          if (existingPlot != null) {
                            existingPlot.name = plot.name;
                            existingPlot.description = plot.description;
                            existingPlot.farmer = plot.farmer;
                            existingPlot.variety = plot.variety;
                            existingPlot.lat = plot.lat;
                            existingPlot.lng = plot.lng;
                            existingPlot.plantationDate = plot.plantationDate;
                            existingPlot.modificationDate = DateTime.now();

                            await plotBox.put(existingPlot.id, existingPlot);

                            for (final measurement in plot.measurements) {
                              if (_measurementExists(
                                measurement.id,
                                existingMeasurements,
                              )) {
                                await _updateMeasurementAndRestorePhotos(
                                  measurement,
                                );
                              } else {
                                await _importMeasurementWithPhotosAndDetections(
                                  measurement,
                                  existingPlot.id,
                                );
                              }
                              restoredMeasurementsCount++;
                            }

                            existingPlotsCount++;
                          } else {
                            final newPlotId = const Uuid().v4();
                            final importedPlot = Plot(
                              id: newPlotId,
                              name: plot.name,
                              userId: currentUser!.id,
                              description: plot.description,
                              farmer: plot.farmer,
                              creationDate: plot.creationDate,
                              modificationDate: DateTime.now(),
                              plantationDate: plot.plantationDate,
                              variety: plot.variety,
                              lat: plot.lat,
                              lng: plot.lng,
                              sourceId: plot.id,
                            );

                            await plotBox.put(newPlotId, importedPlot);

                            for (final measurement in plot.measurements) {
                              await _importMeasurementWithPhotosAndDetections(
                                measurement,
                                newPlotId,
                              );
                              newPlotsMeasurementsCount++;
                            }

                            newPlotsCount++;
                          }
                        }

                        updateState();

                        if (newPlotsCount > 0 || existingPlotsCount > 0) {
                          String message;

                          if (newPlotsCount > 0 && existingPlotsCount == 0) {
                            message = loc.importSummaryOnlyNewPlots(
                              newPlotsMeasurementsCount,
                              newPlotsCount,
                            );
                          } else if (existingPlotsCount > 0 &&
                              newPlotsCount == 0) {
                            if (restoredMeasurementsCount > 0) {
                              message = loc
                                  .importSummaryOnlyExistingWithRestored(
                                    existingPlotsCount,
                                    restoredMeasurementsCount,
                                  );
                            } else {
                              message = loc.importSummaryOnlyExistingNoChanges(
                                existingPlotsCount,
                              );
                            }
                          } else {
                            // Mixed case
                            if (restoredMeasurementsCount > 0) {
                              message = loc.importSummaryMixedWithRestored(
                                newPlotsCount,
                                newPlotsMeasurementsCount,
                                existingPlotsCount,
                                restoredMeasurementsCount,
                                0, // skipped - not tracked in current code
                              );
                            } else {
                              message = loc.importSummaryMixedNoRestored(
                                newPlotsCount,
                                newPlotsMeasurementsCount,
                                existingPlotsCount,
                              );
                            }
                          }

                          customSnackBar(
                            context: context,
                            message: message,
                            type: SnackbarType.success,
                          );
                        } else {
                          customSnackBar(
                            context: context,
                            message: loc.importNoProcessedPlots,
                            type: SnackbarType.info,
                          );
                        }
                      } catch (e) {
                        customSnackBar(
                          context: context,
                          message: loc.actionNotDone,
                          type: SnackbarType.error,
                        );
                      }
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.copy),
                    label: loc.duplicatePlots,
                    elevation: 2,
                    onTap: () {
                      if (plotListOptions.type ==
                          TypesPlotOptionsActions.duplicate) {
                        plotListOptions.changeType(
                          newType: TypesPlotOptionsActions.defaultView,
                          updateState: updateState,
                        );
                      } else {
                        plotListOptions.changeType(
                          newType: TypesPlotOptionsActions.duplicate,
                          updateState: updateState,
                        );
                      }
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.map),
                    label: loc.downloadKML,
                    elevation: 2,
                    onTap: () {
                      if (plotListOptions.type ==
                          TypesPlotOptionsActions.downloadKml) {
                        plotListOptions.changeType(
                          newType: TypesPlotOptionsActions.defaultView,
                          updateState: updateState,
                        );
                      } else {
                        plotListOptions.changeType(
                          newType: TypesPlotOptionsActions.downloadKml,
                          updateState: updateState,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _measurementExists(
    String measurementId,
    List<Measurement> existingMeasurements,
  ) {
    return existingMeasurements.any(
      (m) => m.sourceId == measurementId || m.id == measurementId,
    );
  }

  Future<void> _restoreMissingPhotos(
    MeasurementComplete measurement,
    String existingMeasurementId,
  ) async {
    final photoBox = Hive.box<Photo>(photoBoxName);
    final detectionsBox = Hive.box<Detection>(detectionsBoxName);

    for (final photoComplete in measurement.photos) {
      Photo? existingPhoto;
      for (final p in photoBox.values) {
        if (p.sourceId == photoComplete.id || p.id == photoComplete.id) {
          existingPhoto = p;
          break;
        }
      }

      if (existingPhoto == null) {
        String? galleryPathToUse = photoComplete.galleryPath;
        String? imagePathToUse = photoComplete.imagePath;
        String? originalImagePathToUse = photoComplete.originalImagePath;

        final imageFileExists =
            imagePathToUse != null && File(imagePathToUse).existsSync();
        final originalFileExists =
            originalImagePathToUse != null &&
            File(originalImagePathToUse).existsSync();

        if (!imageFileExists && !originalFileExists) {
          if (galleryPathToUse != null && galleryPathToUse.isNotEmpty) {
            final recoveredPath = await recoverPhotoFromGallery(
              galleryPath: galleryPathToUse,
              originalFileName: imagePathToUse?.split('/').last,
              permissionState: _permissionState,
            );

            if (recoveredPath != null) {
              imagePathToUse = recoveredPath;
            } else {
              imagePathToUse = null;
              originalImagePathToUse = null;
              galleryPathToUse = null;
            }
          } else {
            imagePathToUse = null;
            originalImagePathToUse = null;
            galleryPathToUse = null;
          }
        }

        final newPhotoId = const Uuid().v4();

        final photo = Photo(
          id: newPhotoId,
          measurementId: existingMeasurementId,
          captureDate: photoComplete.captureDate,
          creationDate: photoComplete.creationDate,
          latitude: photoComplete.latitude,
          longitude: photoComplete.longitude,
          imagePath: imagePathToUse,
          galleryPath: galleryPathToUse,
          originalImagePath: originalImagePathToUse,
          sourceId: photoComplete.id,
        );
        await photoBox.put(newPhotoId, photo);

        for (final detection in photoComplete.detections) {
          final newDetectionId = const Uuid().v4();
          final newDetection = Detection(
            id: newDetectionId,
            photoId: newPhotoId,
            confidence: detection.confidence,
            cls: detection.cls,
            x1: detection.x1,
            y1: detection.y1,
            x2: detection.x2,
            y2: detection.y2,
            caliber: detection.caliber,
          );
          await detectionsBox.put(newDetectionId, newDetection);
        }
      }
    }
  }

  Future<bool> _updateMeasurementAndRestorePhotos(
    MeasurementComplete measurement,
  ) async {
    final measurementBox = Hive.box<Measurement>(measurementBoxName);

    Measurement? existingMeasurement;
    for (final m in measurementBox.values) {
      if (m.sourceId == measurement.id || m.id == measurement.id) {
        existingMeasurement = m;
        break;
      }
    }

    if (existingMeasurement == null) return false;

    bool hasChanges = false;

    if (existingMeasurement.name != measurement.name ||
        existingMeasurement.model != measurement.model ||
        existingMeasurement.observations != measurement.observations ||
        existingMeasurement.modificationDate != measurement.modificationDate) {
      hasChanges = true;

      existingMeasurement.name = measurement.name;
      existingMeasurement.model = measurement.model;
      existingMeasurement.observations = measurement.observations;
      existingMeasurement.modificationDate = measurement.modificationDate;

      await measurementBox.put(existingMeasurement.id, existingMeasurement);
    }

    await _restoreMissingPhotos(measurement, existingMeasurement.id);

    return hasChanges;
  }

  PermissionState? _permissionState;

  Future<void> _importMeasurementWithPhotosAndDetections(
    MeasurementComplete measurement,
    String newPlotId,
  ) async {
    final measurementBox = Hive.box<Measurement>(measurementBoxName);
    final photoBox = Hive.box<Photo>(photoBoxName);
    final detectionsBox = Hive.box<Detection>(detectionsBoxName);

    final newMeasurementId = const Uuid().v4();

    final importedMeasurement = Measurement(
      id: newMeasurementId,
      plotId: newPlotId,
      model: measurement.model,
      name: measurement.name,
      observations: measurement.observations,
      creationDate: measurement.creationDate,
      modificationDate: measurement.modificationDate,
      sourceId: measurement.id,
    );

    await measurementBox.put(newMeasurementId, importedMeasurement);

    for (final photoComplete in measurement.photos) {
      String? galleryPathToUse = photoComplete.galleryPath;
      String? imagePathToUse = photoComplete.imagePath;
      String? originalImagePathToUse = photoComplete.originalImagePath;

      final imageFileExists =
          imagePathToUse != null && File(imagePathToUse).existsSync();
      final originalFileExists =
          originalImagePathToUse != null &&
          File(originalImagePathToUse).existsSync();

      if (!imageFileExists && !originalFileExists) {
        if (galleryPathToUse != null && galleryPathToUse.isNotEmpty) {
          final recoveredPath = await recoverPhotoFromGallery(
            galleryPath: galleryPathToUse,
            originalFileName: imagePathToUse?.split('/').last,
            permissionState: _permissionState,
          );

          if (recoveredPath != null) {
            imagePathToUse = recoveredPath;
          } else {
            imagePathToUse = null;
            originalImagePathToUse = null;
            galleryPathToUse = null;
          }
        } else {
          imagePathToUse = null;
          originalImagePathToUse = null;
          galleryPathToUse = null;
        }
      }

      final newPhotoId = const Uuid().v4();

      final photo = Photo(
        id: newPhotoId,
        measurementId: newMeasurementId,
        captureDate: photoComplete.captureDate,
        creationDate: photoComplete.creationDate,
        latitude: photoComplete.latitude,
        longitude: photoComplete.longitude,
        imagePath: imagePathToUse,
        galleryPath: galleryPathToUse,
        originalImagePath: originalImagePathToUse,
        sourceId: photoComplete.id,
      );
      await photoBox.put(newPhotoId, photo);

      for (final detection in photoComplete.detections) {
        final newDetectionId = const Uuid().v4();
        final newDetection = Detection(
          id: newDetectionId,
          photoId: newPhotoId,
          confidence: detection.confidence,
          cls: detection.cls,
          x1: detection.x1,
          y1: detection.y1,
          x2: detection.x2,
          y2: detection.y2,
          caliber: detection.caliber,
        );
        await detectionsBox.put(newDetectionId, newDetection);
      }
    }
  }
}
