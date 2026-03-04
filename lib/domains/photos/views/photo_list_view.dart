import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/components/empty_list_component.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/model_enum.dart';
import 'package:fruit_measure_app/domains/measurements/services/edit_measurement.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurement_view.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/delete_photo.dart';
import 'package:fruit_measure_app/domains/photos/services/execute_photo_taking_work_flow.dart';
import 'package:fruit_measure_app/domains/photos/services/get_photo_complete.dart';
import 'package:fruit_measure_app/domains/photos/views/photo_view.dart';
import 'package:fruit_measure_app/domains/photos/views/photos_statistics_view.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PhotoListViewArguments {
  PhotoListViewArguments({required this.plot, required this.measurement});

  final Plot plot;
  final Measurement measurement;
}

class PhotoListView extends StatefulWidget {
  const PhotoListView({
    super.key,
    required this.plot,
    required this.measurement,
  });

  final Plot plot;
  final Measurement measurement;

  @override
  State<PhotoListView> createState() => _PhotoListViewState();
}

class _PhotoListViewState extends State<PhotoListView>
    with UpdateState<PhotoListView> {
  bool _processing = false;
  int _currentProgress = 0;
  int _totalImages = 0;
  bool _selectionMode = false;
  final Set<String> _selectedPhotos = {};
  bool _navigationPending = false;

  Future<List<PhotoComplete>>? _cachedPhotosFuture;
  List<PhotoComplete>? _cachedSortedPhotos;
  String? _lastMeasurementId;
  int _cacheVersion = 0;

  void _invalidateCache() {
    _cachedPhotosFuture = getPhotoComplete(
      measurementId: widget.measurement.id,
    );
    _cachedSortedPhotos = null;
    _cacheVersion++;
  }

  @override
  void initState() {
    super.initState();
    _cachedPhotosFuture = getPhotoComplete(
      measurementId: widget.measurement.id,
    );
    _lastMeasurementId = widget.measurement.id;
  }

  @override
  void didUpdateWidget(PhotoListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.measurement.id != widget.measurement.id) {
      _invalidateCache();
      _lastMeasurementId = widget.measurement.id;
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

    return FutureBuilder<List<PhotoComplete>>(
      key: ValueKey<int>(
        _cacheVersion,
      ), 
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

        final List<PhotoComplete> photosComplete = snapshot.data!;

        if (_cachedSortedPhotos == null ||
            _lastMeasurementId != widget.measurement.id) {
          _cachedSortedPhotos =
              photosComplete.sortedByDescending((e) => e.captureDate).toList();
          _lastMeasurementId = widget.measurement.id;
        }

        final List<PhotoComplete> sortedPhotos = _cachedSortedPhotos!;
        final int count = sortedPhotos.length;

        return Stack(
          children: [
            Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child:
                    _selectionMode
                        ? AppBar(
                          leading: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectionMode = false;
                                _selectedPhotos.clear();
                              });
                            },
                          ),
                          title: Text(
                            '${_selectedPhotos.length} ${_selectedPhotos.length == 1 ? loc.fruit : loc.fruits}',
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                bool deleteFromGallery = false;

                                final bool? confirmed = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => StatefulBuilder(
                                        builder:
                                            (context, setState) => AlertDialog(
                                              title: Text(
                                                loc.confirmDeleteElementTitle,
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    loc.confirmDeleteElementMessage,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  CheckboxListTile(
                                                    title: Text(
                                                      loc.deleteFromGalleryLabel,
                                                    ),
                                                    subtitle: Text(
                                                      loc.deleteFromGalleryDescription,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    value: deleteFromGallery,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        deleteFromGallery =
                                                            value ?? false;
                                                      });
                                                    },
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(false),
                                                  child: Text(loc.cancel),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(true),
                                                  child: Text(loc.confirm),
                                                ),
                                              ],
                                            ),
                                      ),
                                );

                                if (confirmed == true) {
                                  bool hasError = false;
                                  for (final photoId in _selectedPhotos) {
                                    try {
                                      await deletePhoto(
                                        photoId,
                                        deleteFromGallery: deleteFromGallery,
                                      );
                                    } catch (e) {
                                      hasError = true;
                                      if (kDebugMode) {
                                        print(
                                          'Failed to delete photo $photoId: $e',
                                        );
                                      }
                                    }
                                  }

                                  setState(() {
                                    _selectedPhotos.clear();
                                    _selectionMode = false;
                                  });

                                  if (hasError) {
                                    customSnackBar(
                                      context: context,
                                      message: loc.errorDeletePhotoFailed,
                                      type: SnackbarType.error,
                                    );
                                  } else {
                                    customSnackBar(
                                      context: context,
                                      message: loc.actionDone,
                                      type: SnackbarType.success,
                                    );
                                  }

                                  _invalidateCache();
                                  updateState();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                _selectedPhotos.length == count
                                    ? Icons.deselect
                                    : Icons.select_all,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_selectedPhotos.length == count) {
                                    _selectedPhotos.clear();
                                    _selectionMode = false;
                                  } else {
                                    _selectedPhotos.clear();
                                    for (final photo in sortedPhotos) {
                                      _selectedPhotos.add(photo.id);
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                        : CustomAppBar(title: loc.dataMeasurement),
              ),
              endDrawer: _selectionMode ? null : const AccountEndDrawer(),
              drawerBarrierDismissible: false,
              endDrawerEnableOpenDragGesture: false,
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.plot.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final arguments = MeasurementViewArguments(
                              measurement: widget.measurement,
                            );
                            Navigator.of(context)
                                .pushNamed('/measurement', arguments: arguments)
                                .then((value) {
                                  _invalidateCache();
                                  updateState();
                                });
                          },
                          icon: const Icon(Icons.edit, color: Colors.black),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            widget.measurement.name ?? '',
                            style: const TextStyle(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<Model>(
                            value: widget.measurement.model,
                            onChanged: (Model? value) {
                              if (value != null) {
                                setState(() {
                                  widget.measurement.model = value;
                                });

                                editMeasurement(widget.measurement);

                                customSnackBar(
                                  context: context,
                                  message:
                                      '${loc.modelUpdateTo} ${value.getModelName(loc).toLowerCase()}',
                                  type: SnackbarType.info,
                                );
                              }
                            },
                            items:
                                // Model.values.map((model) {
                                //   return DropdownMenuItem<Model>(
                                //     value: model,
                                //     child: Text(model.getModelName(loc)),
                                //   );
                                // }).toList(),
                                // Caixa temporalmente deshabilitado:
                                Model.values
                                    .where((model) => model != Model.caixa)
                                    .map((model) {
                                  return DropdownMenuItem<Model>(
                                    value: model,
                                    child: Text(model.getModelName(loc)),
                                  );
                                }).toList(),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(widget.measurement.creationDate),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      overflow:
                          TextOverflow.ellipsis, // para evitar desbordamiento
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          count > 0
                              ? ListView.builder(
                                itemCount: count,
                                itemBuilder: (context, index) {
                                  final photoComplete = sortedPhotos[index];

                                  final isSelected = _selectedPhotos.contains(
                                    photoComplete.id,
                                  );

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    selected: isSelected,
                                    selectedTileColor: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    leading:
                                        _selectionMode
                                            ? Checkbox(
                                              value: isSelected,
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedPhotos.add(
                                                      photoComplete.id,
                                                    );
                                                  } else {
                                                    _selectedPhotos.remove(
                                                      photoComplete.id,
                                                    );
                                                  }
                                                });
                                              },
                                            )
                                            : Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.tertiary,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: const Icon(
                                                Icons.photo,
                                                size: 28,
                                              ),
                                            ),
                                    title: Text(
                                      photoComplete.getAllCalibersAsString(loc),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    subtitle: Text(
                                      DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      ).format(photoComplete.captureDate),
                                    ),
                                    trailing:
                                        _selectionMode
                                            ? null
                                            : const Icon(Icons.chevron_right),
                                    onTap: () {
                                      if (_selectionMode) {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedPhotos.remove(
                                              photoComplete.id,
                                            );
                                          } else {
                                            _selectedPhotos.add(
                                              photoComplete.id,
                                            );
                                          }

                                          if (_selectedPhotos.isEmpty) {
                                            _selectionMode = false;
                                          }
                                        });
                                      } else {
                                        final arguments = PhotoViewArguments(
                                          photo: photoComplete,
                                          takenImage: null,

                                          isCreatePhoto: false,
                                        );
                                        Navigator.of(context)
                                            .pushNamed(
                                              '/photo',
                                              arguments: arguments,
                                            )
                                            .then((value) {
                                              _invalidateCache();
                                              updateState();
                                            });
                                      }
                                    },
                                    onLongPress: () {
                                      // Activar modo selección y seleccionar esta foto
                                      setState(() {
                                        _selectionMode = true;
                                        _selectedPhotos.add(photoComplete.id);
                                      });
                                    },
                                  );
                                },
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  EmptyListComponent(
                                    icon: Icons.image_rounded,
                                    title: loc.noImageCaptured,
                                    description: loc.noCaptureForMeasurement,
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
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
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
                              final arguments = PhotosStatisticsViewArguments(
                                plot: widget.plot,
                                measurement: widget.measurement,
                              );
                              Navigator.of(context)
                                  .pushNamed(
                                    '/photos-statistics',
                                    arguments: arguments,
                                  )
                                  .then((value) {
                                    _invalidateCache();
                                    updateState();
                                  });
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 24,
                      bottom: 24,
                      child: SpeedDial(
                        icon: Icons.photo_camera,
                        activeIcon: Icons.close,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        heroTag: 'SpeedDialRight',
                        spaceBetweenChildren: 5,
                        spacing: 10,
                        children: [
                          SpeedDialChild(
                            child: const Icon(Icons.photo_camera),
                            label: loc.makeCapture,
                            elevation: 2,
                            onTap: () async {
                              await executePhotoTakingWorkflow(
                                context: context,
                                takingType: ImageSource.camera,
                                updateState: () {
                                  _invalidateCache();
                                  updateState();
                                },
                                setProcessing:
                                    (value) =>
                                        setState(() => _processing = value),
                                distFruitToCamMm: currentUser!.supportDistance,
                                measurement: widget.measurement,
                              );
                              _invalidateCache();
                              updateState();
                            },
                          ),
                          SpeedDialChild(
                            child: const Icon(Icons.photo_library),
                            label: loc.selectImageFromGallery,
                            elevation: 2,
                            onTap: () async {
                              await executePhotoTakingWorkflow(
                                context: context,
                                takingType: ImageSource.gallery,
                                updateState: () {
                                  _invalidateCache();
                                  updateState();
                                },
                                setProcessing:
                                    (value) =>
                                        setState(() => _processing = value),
                                setProgress:
                                    (current, total) => setState(() {
                                      _currentProgress = current;
                                      _totalImages = total;
                                    }),
                                distFruitToCamMm: currentUser!.supportDistance,
                                measurement: widget.measurement,
                              );
                              _invalidateCache();
                              updateState();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_processing)
              Container(
                color: Colors.black45,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        _totalImages > 0 && _currentProgress > 0
                            ? '${loc.processingImages} $_currentProgress ${loc.ofTotal} $_totalImages'
                            : (_totalImages > 0
                                ? loc.selectingImages
                                : loc.loadingProcessingImage),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      if (_totalImages > 0) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            value:
                                _totalImages > 0
                                    ? _currentProgress / _totalImages
                                    : 0,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
