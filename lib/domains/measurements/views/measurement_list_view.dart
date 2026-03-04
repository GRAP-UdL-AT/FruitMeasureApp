import 'dart:io';

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
import 'package:fruit_measure_app/domains/measurements/models/measurement_options_actions.dart';
import 'package:fruit_measure_app/domains/measurements/models/types_measurement_options_actions.dart';
import 'package:fruit_measure_app/domains/measurements/services/export_measurements.dart';
import 'package:fruit_measure_app/domains/measurements/services/import_measurements.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurement_view.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurements_calendar_view.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurements_multi_growth_curve_stadistics_view.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurements_stadistics_view.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/services/recover_photo_from_gallery.dart';
import 'package:fruit_measure_app/domains/photos/views/photo_list_view.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/plots/views/plot_view.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:uuid/uuid.dart';

class MeasurementListViewArguments {
  MeasurementListViewArguments({required this.plot});

  final Plot plot;
}

class MeasurementListView extends StatefulWidget {
  const MeasurementListView({super.key, required this.plot});

  final Plot plot;

  @override
  State<MeasurementListView> createState() => _MeasurementListViewState();
}

class _MeasurementListViewState extends State<MeasurementListView>
    with UpdateState<MeasurementListView> {
  final measurementsActions = MeasurementOptionsActions(
    measurements: [],
    type: TypesMeasurementOptionsActions.defaultView,
  );

  String searchQuery = '';
  PermissionState? _permissionState;
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

    final List<Measurement> measurements =
        measurementBox.values
            .where(
              (measurement) =>
                  measurement.plotId == widget.plot.id &&
                  measurement.searchField.toLowerCase().contains(searchQuery),
            )
            .sortedByDescending((e) => e.creationDate)
            .toList();

    return Scaffold(
      appBar: CustomAppBar(title: loc.measurementsLabel),
      endDrawer: const AccountEndDrawer(),
      drawerBarrierDismissible: false,
      endDrawerEnableOpenDragGesture: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.plot.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final arguments = PlotViewArguments(plot: widget.plot);
                    Navigator.of(context)
                        .pushNamed('/plot', arguments: arguments)
                        .then((value) => updateState());
                  },
                  icon: const Icon(Icons.edit, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              [
                widget.plot.farmer,
                widget.plot.variety,
                DateFormat('dd/MM/yyyy').format(widget.plot.plantationDate),
              ].where((e) => e.isNotEmpty).join(', '),
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: loc.searchMeasurement,
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
                  measurements.isNotEmpty
                      ? ListView.builder(
                        itemCount: measurements.length,
                        itemBuilder: (context, index) {
                          final measurement = measurements[index];
                          final photos =
                              Hive.box<Photo>(photoBoxName).values
                                  .where(
                                    (p) => p.measurementId == measurement.id,
                                  )
                                  .toList();
                          final calibers =
                              Hive.box<Detection>(detectionsBoxName).values
                                  .where(
                                    (d) => photos.any((p) => p.id == d.photoId),
                                  )
                                  .map((d) => d.caliber)
                                  .toList();
                          final avgDiameter =
                              calibers.isNotEmpty ? calibers.average() : null;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            leading: measurementsActions.getRadioValues(
                              context: context,
                              measurement: measurement,
                              updateState: updateState,
                            ),
                            title: Text(
                              measurement.name != null &&
                                      measurement.name!.isNotEmpty
                                  ? '${measurement.name}'
                                  : DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(measurement.creationDate),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              [
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(measurement.creationDate),
                                if (avgDiameter != null)
                                  'Ø ${avgDiameter.toStringAsFixed(1)} mm',
                                measurement.model?.getModelName(loc) ?? '',
                              ].where((e) => e.isNotEmpty).join(' · '),
                            ),

                            trailing:
                                measurementsActions.type ==
                                        TypesMeasurementOptionsActions
                                            .defaultView
                                    ? const Icon(Icons.chevron_right)
                                    : null,
                            onTap: () {
                              measurementsActions.onTap(
                                context: context,
                                updateState: updateState,
                                plot: widget.plot,
                                measurement: measurement,
                              );
                            },
                          );
                        },
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EmptyListComponent(
                            icon: Icons.bar_chart_rounded,
                            title: loc.withoutMeasurements,
                            description: loc.noMeasurementsRegistered,
                          ),
                        ],
                      ),
            ),
            if (measurementsActions.type !=
                TypesMeasurementOptionsActions.defaultView)
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
                          measurementsActions.changeType(
                            newType: TypesMeasurementOptionsActions.defaultView,
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
                            measurementsActions.measurements.isEmpty
                                ? null
                                : () async {
                                  if (measurementsActions.type ==
                                      TypesMeasurementOptionsActions.export) {
                                    final ExportFormat?
                                    selectedFormat = await showDialog<
                                      ExportFormat
                                    >(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text(loc.exportFormat),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    loc.exportFormatJson,
                                                  ),
                                                  subtitle: Text(
                                                    loc.exportFormatJsonDescription,
                                                  ),
                                                  leading: const Icon(
                                                    Icons.code,
                                                  ),
                                                  onTap:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(ExportFormat.json),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                    loc.exportFormatCsv,
                                                  ),
                                                  subtitle: Text(
                                                    loc.exportFormatCsvDescription,
                                                  ),
                                                  leading: const Icon(
                                                    Icons.table_chart,
                                                  ),
                                                  onTap:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(ExportFormat.csv),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                    loc.exportFormatTxt,
                                                  ),
                                                  subtitle: Text(
                                                    loc.exportFormatTxtDescription,
                                                  ),
                                                  leading: const Icon(
                                                    Icons.description,
                                                  ),
                                                  onTap:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(ExportFormat.txt),
                                                ),
                                              ],
                                            ),
                                          ),
                                    );

                                    if (selectedFormat == null) return;

                                    try {
                                      final filePath = await exportMeasurements(
                                        measurementsActions.measurements,
                                        format: selectedFormat,
                                        loc: loc,
                                      );
                                      if (filePath == null) return;

                                      customSnackBar(
                                        context: context,
                                        message: loc.actionDone,
                                        type: SnackbarType.success,
                                      );
                                    } catch (e) {
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

                                    measurementsActions.changeType(
                                      newType:
                                          TypesMeasurementOptionsActions
                                              .defaultView,
                                      updateState: updateState,
                                    );
                                  }

                                  if (measurementsActions.type ==
                                      TypesMeasurementOptionsActions
                                          .compareCharts) {
                                    final arguments =
                                        MeasurementsStatisticsViewArguments(
                                          measurements:
                                              measurementsActions.measurements,
                                        );
                                    await Navigator.of(context).pushNamed(
                                      '/measurements-stadistics-view',
                                      arguments: arguments,
                                    );
                                  }
                                },

                        child: Text(
                          loc.accept,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                measurementsActions.measurements.isNotEmpty
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
                icon: Icons.bar_chart,
                activeIcon: Icons.close,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                heroTag: 'SpeedDialLeft',
                spaceBetweenChildren: 5,
                spacing: 10,
                switchLabelPosition: true,
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.bar_chart),
                    label: loc.statistics,
                    elevation: 2,
                    onTap: () {
                      if (measurements.isNotEmpty) {
                        measurementsActions.changeType(
                          newType: TypesMeasurementOptionsActions.compareCharts,
                          updateState: updateState,
                        );
                      } else {
                        customSnackBar(
                          context: context,
                          message: loc.withoutMeasurements,
                          type: SnackbarType.error,
                        );
                      }
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.show_chart),
                    label: loc.growthCurve,
                    elevation: 2,
                    onTap: () {
                      if (measurements.isNotEmpty) {
                        final arguments =
                            MeasurementsMultiGrowthCurveStatisticsViewArguments(
                              plots: [widget.plot],
                            );
                        Navigator.of(context)
                            .pushNamed(
                              '/measurements-growth-curve-statistics',
                              arguments: arguments,
                            )
                            .then((value) => updateState());
                      } else {
                        customSnackBar(
                          context: context,
                          message: loc.withoutMeasurements,
                          type: SnackbarType.error,
                        );
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
                    label: loc.createMeasurement,
                    elevation: 2,
                    onTap: () {
                      final newMeasurement = Measurement(
                        id: const Uuid().v4(),
                        plotId: widget.plot.id,
                        creationDate: DateTime.now(),
                        modificationDate: DateTime.now(),
                        model: null,
                        name: '',
                        observations: '',
                      );
                      final arguments = MeasurementViewArguments(
                        measurement: newMeasurement,
                        isCreateMeasurement: true,
                      );
                      Navigator.of(context)
                          .pushNamed('/measurement', arguments: arguments)
                          .then((value) {
                            if (value is Measurement) {
                              final arguments = PhotoListViewArguments(
                                plot: widget.plot,
                                measurement: value,
                              );
                              Navigator.of(context)
                                  .pushNamed('/photos', arguments: arguments)
                                  .then((value) => updateState());
                            } else if (value == true) {
                              customSnackBar(
                                context: context,
                                message: loc.actionDone,
                                type: SnackbarType.success,
                              );
                              updateState();
                            }
                            updateState();
                          });
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.file_upload),
                    label: loc.exportMeasurements,
                    elevation: 2,
                    onTap: () {
                      measurementsActions.changeType(
                        newType: TypesMeasurementOptionsActions.export,
                        updateState: updateState,
                      );
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.file_download),
                    label: loc.importMeasurements,
                    elevation: 2,
                    onTap: () async {
                      try {
                        final ps = await PhotoManager.requestPermissionExtend();
                        _permissionState = ps;

                        final result = await importMeasurements();

                        if (result.hasError) {
                          if (result.errorType ==
                              ImportMeasurementsErrorType.cancelled) {
                            return;
                          }

                          String errorMessage;
                          switch (result.errorMessage) {
                            case 'wrongFileTypePlot':
                              errorMessage = loc.errorImportWrongFilePlot;
                              break;
                            case 'wrongFileTypeGeneric':
                              errorMessage =
                                  loc.errorImportWrongFileGenericMeasurements;
                              break;
                            case 'emptyFile':
                              errorMessage = loc.errorImportEmptyFile;
                              break;
                            case 'noMeasurements':
                              errorMessage = loc.errorImportNoMeasurements;
                              break;
                            case 'parseError':
                              errorMessage =
                                  loc.errorImportParseErrorMeasurements;
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

                        if (result.measurements.isEmpty) {
                          return;
                        }

                        int importedCount = 0;
                        int restoredCount = 0;
                        int existingCount = 0;

                        final existingMeasurements = measurements.toList();

                        for (final measurement in result.measurements) {
                          if (measurement.plotId != widget.plot.id) {
                            continue;
                          }

                          if (_measurementExists(
                            measurement.id,
                            existingMeasurements,
                          )) {
                            final hadChanges =
                                await _updateMeasurementAndRestorePhotos(
                                  measurement,
                                );
                            if (hadChanges) {
                              restoredCount++;
                            } else {
                              existingCount++;
                            }
                          } else {
                            await _importMeasurementWithPhotosAndDetections(
                              measurement,
                            );
                            importedCount++;
                          }
                        }

                        updateState();

                        final totalProcessed =
                            importedCount + restoredCount + existingCount;

                        if (importedCount > 0 || restoredCount > 0) {
                          String message;

                          if (importedCount > 0 && restoredCount == 0) {
                            message = loc.importMeasurementsOnlyNew(
                              importedCount,
                            );
                          } else if (restoredCount > 0 && importedCount == 0) {
                            message = loc.importMeasurementsOnlyUpdated(
                              restoredCount,
                            );
                          } else {
                            message = loc.importMeasurementsMixed(
                              importedCount,
                              restoredCount,
                            );
                          }

                          customSnackBar(
                            context: context,
                            message: message,
                            type: SnackbarType.success,
                          );
                        } else if (existingCount > 0) {
                          customSnackBar(
                            context: context,
                            message: loc.allMeasurementsAlreadyImported,
                            type: SnackbarType.info,
                          );
                        } else if (totalProcessed == 0) {
                          customSnackBar(
                            context: context,
                            message: loc.noMeasurementsForThisPlot,
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
                    child: const Icon(Icons.calendar_month),
                    label: loc.calendarView,
                    elevation: 2,
                    onTap: () {
                      final arguments = MeasurementsCalendarViewArguments(
                        plot: widget.plot,
                      );
                      Navigator.of(context)
                          .pushNamed(
                            '/measurements-calendar',
                            arguments: arguments,
                          )
                          .then((value) => updateState());
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
    return existingMeasurements.any((m) => m.id == measurementId);
  }

  Future<void> _restoreMissingPhotos(MeasurementComplete measurement) async {
    final photoBox = Hive.box<Photo>(photoBoxName);
    final detectionsBox = Hive.box<Detection>(detectionsBoxName);

    for (final photoComplete in measurement.photos) {
      final existingPhoto = photoBox.get(photoComplete.id);

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

        final photo = Photo(
          id: photoComplete.id,
          measurementId: photoComplete.measurementId,
          captureDate: photoComplete.captureDate,
          creationDate: photoComplete.creationDate,
          latitude: photoComplete.latitude,
          longitude: photoComplete.longitude,
          imagePath: imagePathToUse,
          galleryPath: galleryPathToUse,
          originalImagePath: originalImagePathToUse,
        );
        await photoBox.put(photo.id, photo);

        for (final detection in photoComplete.detections) {
          await detectionsBox.put(detection.id, detection);
        }
      }
    }
  }

  Future<bool> _updateMeasurementAndRestorePhotos(
    MeasurementComplete measurement,
  ) async {
    final measurementBox = Hive.box<Measurement>(measurementBoxName);
    final existingMeasurement = measurementBox.get(measurement.id);

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

      await measurementBox.put(measurement.id, existingMeasurement);
    }

    await _restoreMissingPhotos(measurement);

    return hasChanges;
  }

  Future<void> _importMeasurementWithPhotosAndDetections(
    MeasurementComplete measurement,
  ) async {
    final measurementBox = Hive.box<Measurement>(measurementBoxName);
    final photoBox = Hive.box<Photo>(photoBoxName);
    final detectionsBox = Hive.box<Detection>(detectionsBoxName);

    final importedMeasurement = Measurement(
      id: measurement.id,
      plotId: measurement.plotId,
      model: measurement.model,
      name: measurement.name,
      observations: measurement.observations,
      creationDate: measurement.creationDate,
      modificationDate: measurement.modificationDate,
    );

    await measurementBox.put(measurement.id, importedMeasurement);

    for (final photoComplete in measurement.photos) {
      final existingPhoto = photoBox.get(photoComplete.id);

      String? galleryPathToUse = photoComplete.galleryPath;
      String? imagePathToUse = photoComplete.imagePath;
      String? originalImagePathToUse = photoComplete.originalImagePath;

      final imageFileExists =
          imagePathToUse != null && File(imagePathToUse).existsSync();
      final originalFileExists =
          originalImagePathToUse != null &&
          File(originalImagePathToUse).existsSync();

      if (!imageFileExists && !originalFileExists) {
        if (existingPhoto != null && existingPhoto.galleryPath != null) {
          galleryPathToUse = existingPhoto.galleryPath;
        }

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

      final photo = Photo(
        id: photoComplete.id,
        measurementId: photoComplete.measurementId,
        captureDate: photoComplete.captureDate,
        creationDate: photoComplete.creationDate,
        latitude: photoComplete.latitude,
        longitude: photoComplete.longitude,
        imagePath: imagePathToUse,
        galleryPath: galleryPathToUse,
        originalImagePath: originalImagePathToUse,
      );
      await photoBox.put(photo.id, photo);

      for (final detection in photoComplete.detections) {
        await detectionsBox.put(detection.id, detection);
      }
    }
  }
}
