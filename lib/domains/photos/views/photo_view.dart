import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/colors.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/components/google_maps_container.dart';
import 'package:fruit_measure_app/domains/detections/services/edit_detection.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/delete_photo.dart';
import 'package:fruit_measure_app/domains/photos/services/edit_photo.dart';
import 'package:fruit_measure_app/domains/photos/services/execute_photo_taking_work_flow.dart';
import 'package:fruit_measure_app/domains/photos/services/recover_photo_from_gallery.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:hive_ce/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart' as photo_view_package;

class PhotoViewArguments {
  PhotoViewArguments({
    required this.photo,
    required this.takenImage,

    required this.isCreatePhoto,
  });

  final PhotoComplete photo;
  final XFile? takenImage;
  final bool isCreatePhoto;
}

class PhotoView extends StatefulWidget {
  const PhotoView({
    super.key,
    required this.photo,
    required this.takenImage,
    required this.isCreatePhoto,
    this.takingType,
  });

  final PhotoComplete photo;
  final XFile? takenImage;
  final bool isCreatePhoto;
  final ImageSource? takingType;

  @override
  State<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> with UpdateState<PhotoView> {
  late bool isEditing;

  double? _lat;
  double? _lng;
  bool _attemptedGalleryRecovery = false;
  bool _isRecoveringFromGallery = false;

  late final List<TextEditingController> _caliberControllers;

  void _confirmDelete() {
    bool deleteFromGallery = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.confirmDeleteElementTitle,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.confirmDeleteElementMessage,
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: Text(
                          AppLocalizations.of(context)!.deleteFromGalleryLabel,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!.deleteFromGalleryDescription,
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: deleteFromGallery,
                        onChanged: (value) {
                          setState(() {
                            deleteFromGallery = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () async {
                        await deletePhoto(
                          widget.photo.id,
                          deleteFromGallery: deleteFromGallery,
                        );
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _confirmPhotoChanges() {
    final loc = AppLocalizations.of(context)!;
    isEditing = false;

    for (int i = 0; i < _caliberControllers.length; i++) {
      final text =
          _caliberControllers[i].text
              .trim()
              .replaceAll(',', '.')
              .replaceAll('mm', '')
              .trim();
      final parsed = double.tryParse(text);
      if (parsed != null) {
        widget.photo.detections[i].caliber = parsed;
      }
    }

    widget.photo.latitude = _lat;
    widget.photo.longitude = _lng;

    for (final detection in widget.photo.detections) {
      editDetection(detection);
    }

    editPhoto(widget.photo);

    Navigator.of(context).pop();

    if (widget.isCreatePhoto) {
      Navigator.of(context).pop();
    } else {
      updateState();
    }

    customSnackBar(
      context: context,
      message: loc.actionDone,
      type: SnackbarType.success,
    );
  }

  @override
  void initState() {
    super.initState();
    isEditing = false;
    _lat = widget.photo.latitude;
    _lng = widget.photo.longitude;
    _caliberControllers =
        widget.photo.detections
            .map(
              (d) => TextEditingController(text: d.caliber.toStringAsFixed(1)),
            )
            .toList();

    _attemptGalleryRecoveryIfNeeded();
  }

  Future<void> _attemptGalleryRecoveryIfNeeded() async {
    if (_attemptedGalleryRecovery) return;

    final needsRecovery =
        (widget.photo.imagePath == null ||
            widget.photo.imagePath!.isEmpty ||
            !File(widget.photo.imagePath!).existsSync()) &&
        (widget.photo.originalImagePath == null ||
            widget.photo.originalImagePath!.isEmpty ||
            !File(widget.photo.originalImagePath!).existsSync()) &&
        widget.photo.galleryPath != null &&
        widget.photo.galleryPath!.isNotEmpty;

    if (!needsRecovery) return;

    _attemptedGalleryRecovery = true;

    if (mounted) {
      setState(() {
        _isRecoveringFromGallery = true;
      });
    }

    final recoveredPath = await recoverPhotoFromGallery(
      galleryPath: widget.photo.galleryPath,
      originalFileName: widget.photo.imagePath?.split('/').last,
    );

    if (mounted) {
      if (recoveredPath != null) {
        widget.photo.imagePath = recoveredPath;
        final photoBox = Hive.box<Photo>(photoBoxName);
        await photoBox.put(widget.photo.id, widget.photo);
      }

      setState(() {
        _isRecoveringFromGallery = false;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _caliberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final String? imagePath =
        widget.takenImage?.path ??
        (widget.photo.imagePath != null &&
                widget.photo.imagePath!.isNotEmpty &&
                File(widget.photo.imagePath!).existsSync()
            ? widget.photo.imagePath
            : (widget.photo.originalImagePath != null &&
                    widget.photo.originalImagePath!.isNotEmpty &&
                    File(widget.photo.originalImagePath!).existsSync()
                ? widget.photo.originalImagePath
                : null));

    return Scaffold(
      appBar: CustomAppBar(title: loc.dataMeasurement),
      endDrawer: const AccountEndDrawer(),
      drawerBarrierDismissible: false,
      endDrawerEnableOpenDragGesture: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),

                          Card(
                            elevation: 0,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              loc.caliber,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'dd/MM/yyyy HH:mm',
                                            ).format(widget.photo.captureDate),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),

                                  Column(
                                    children: List.generate(
                                      (widget.photo.detections.length / 2)
                                          .ceil(),
                                      (rowIndex) {
                                        final start = rowIndex * 2;
                                        final end = (start + 2).clamp(
                                          0,
                                          widget.photo.detections.length,
                                        );
                                        final items = widget.photo.detections
                                            .sublist(start, end);
                                        return Row(
                                          children: List.generate(items.length, (
                                            index,
                                          ) {
                                            final detectionIndex =
                                                start + index;
                                            return Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (widget
                                                              .photo
                                                              .detections
                                                              .length >
                                                          1)
                                                        Column(
                                                          children: [
                                                            Text(
                                                              '${loc.detectionFruit} ${detectionIndex + 1}',
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                          ],
                                                        )
                                                      else
                                                        const SizedBox(),

                                                      TextField(
                                                        enabled: isEditing,
                                                        controller:
                                                            _caliberControllers[detectionIndex],
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            const InputDecoration(
                                                              suffixText: 'mm',
                                                            ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  const SizedBox(height: 16),

                                  if (widget.photo.imagePath == null &&
                                      imagePath ==
                                          widget.photo.originalImagePath &&
                                      imagePath != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        border: Border.all(
                                          color: Colors.orange.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info,
                                            color: Colors.orange.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              loc.selectImageFromGallery,
                                              style: TextStyle(
                                                color: Colors.orange.shade700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (imagePath != null &&
                                      imagePath.isNotEmpty &&
                                      File(imagePath).existsSync()) ...[
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            fullscreenDialog: true,
                                            builder:
                                                (context) =>
                                                    FullscreenImageViewer(
                                                      imagePath: imagePath,
                                                      title:
                                                          loc.dataMeasurement,
                                                    ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(imagePath),
                                          key: ValueKey(imagePath),
                                          width: double.infinity,
                                          height: 500,
                                          fit: BoxFit.cover,
                                          cacheWidth: 1200,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (imagePath == null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color:
                                            _isRecoveringFromGallery
                                                ? Colors.blue.shade50
                                                : Colors.grey.shade100,
                                        border: Border.all(
                                          color:
                                              _isRecoveringFromGallery
                                                  ? Colors.blue.shade300
                                                  : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_isRecoveringFromGallery) ...[
                                            const SizedBox(
                                              width: 64,
                                              height: 64,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 4,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              loc.loadingProcessingImage,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade800,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              loc.recoveringImageFromGallery,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue.shade700,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ] else ...[
                                            Icon(
                                              Icons.image_not_supported,
                                              size: 64,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              loc.imageNotAvailable,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade800,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              loc.imageNotAvailableDescription,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Card(
                            elevation: 0,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      loc.locationDialogTitle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                            labelText: '${loc.latitude} (°)',
                                          ),
                                          controller: TextEditingController(
                                            text:
                                                _lat != null
                                                    ? '${NumberFormat.decimalPatternDigits(locale: 'es_ES', decimalDigits: 6).format(_lat!.abs())}° ${_lat! >= 0 ? 'N' : 'S'}'
                                                    : loc.notAvalaible,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                            labelText: '${loc.longitude} (°)',
                                          ),
                                          controller: TextEditingController(
                                            text:
                                                _lng != null
                                                    ? '${NumberFormat.decimalPatternDigits(locale: 'es_ES', decimalDigits: 6).format(_lng!.abs())}° ${_lng! >= 0 ? 'E' : 'W'}'
                                                    : loc.notAvalaible,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => Dialog.fullscreen(
                                              child: Scaffold(
                                                appBar: AppBar(
                                                  leading: IconButton(
                                                    icon: const Icon(
                                                      Icons.arrow_back,
                                                    ),
                                                    onPressed:
                                                        () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(),
                                                  ),
                                                  title: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.locationDialogTitle,
                                                  ),
                                                ),
                                                body: GoogleMapsContainer(
                                                  lat: _lat,
                                                  lng: _lng,
                                                  enabled: isEditing,
                                                  showButtons: true,
                                                  onChange: (lat, lng) {
                                                    _lat = lat;
                                                    _lng = lng;
                                                    updateState();
                                                  },
                                                ),
                                              ),
                                            ),
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: IgnorePointer(
                                            child: SizedBox(
                                              height: 200,
                                              width: double.infinity,
                                              child: GoogleMapsContainer(
                                                key: Key('$_lat$_lng'),
                                                lat: _lat,
                                                lng: _lng,
                                                enabled: false,
                                                showButtons: false,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: Colors.black.withAlpha(77),
                                          ),
                                          child: Center(
                                            child: Text(
                                              isEditing
                                                  ? AppLocalizations.of(
                                                    context,
                                                  )!.tapToEditMap
                                                  : AppLocalizations.of(
                                                    context,
                                                  )!.tapToViewMap,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.isCreatePhoto && !isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: btnRedLight,
                              ),
                              onPressed: _confirmDelete,
                              icon: const Icon(
                                Icons.delete,
                                color: btnRedDark,
                                size: 18,
                              ),
                              label: Text(
                                loc.delete,
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
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: btnGreenLight,
                              ),
                              onPressed: () async {
                                final ImageSource? selectedSource =
                                    await showModalBottomSheet<ImageSource>(
                                      context: context,
                                      builder: (context) {
                                        return ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minHeight: 125,
                                            maxHeight: 225,
                                          ),
                                          child: Wrap(
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.camera_alt,
                                                ),
                                                title: Text(loc.camera),
                                                onTap: () {
                                                  Navigator.of(
                                                    context,
                                                  ).pop(ImageSource.camera);
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.photo_library,
                                                ),
                                                title: Text(loc.gallery),
                                                onTap: () {
                                                  Navigator.of(
                                                    context,
                                                  ).pop(ImageSource.gallery);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );

                                if (selectedSource != null) {
                                  await executePhotoTakingWorkflow(
                                    context: context,
                                    takingType: selectedSource,

                                    updateState: updateState,
                                    setProcessing:
                                        (value) => setState(() => false),
                                    distFruitToCamMm:
                                        currentUser!.supportDistance,
                                    measurementId: widget.photo.measurementId,
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.add,
                                color: btnGreenDark,
                                size: 18,
                              ),
                              label: Text(
                                loc.takeNewShot,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: btnGreenDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (isEditing && !widget.isCreatePhoto) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnGreenLight,
                        ),
                        onPressed: () {
                          _confirmPhotoChanges();
                          updateState();
                        },
                        icon: const Icon(
                          Icons.save,
                          color: btnGreenDark,
                          size: 18,
                        ),
                        label: Text(
                          loc.saveChanges,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnGreenDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: btnRedLight,
                              ),
                              onPressed: _confirmDelete,
                              icon: const Icon(
                                Icons.delete,
                                color: btnRedDark,
                                size: 18,
                              ),
                              label: Text(
                                loc.delete,
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
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: btnGreyLight,
                              ),
                              icon: const Icon(
                                Icons.cancel,
                                color: btnGreyDark,
                                size: 18,
                              ),
                              onPressed: () {
                                if (widget.isCreatePhoto) {
                                  Navigator.of(context).pop();
                                } else {
                                  isEditing = false;
                                  updateState();
                                }
                              },
                              label: Text(
                                loc.cancel,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: btnGreyDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (!widget.isCreatePhoto && !isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: btnRedLight,
                              ),
                              onPressed: _confirmDelete,
                              icon: const Icon(
                                Icons.delete,
                                color: btnRedDark,
                                size: 18,
                              ),
                              label: Text(
                                loc.delete,
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
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: btnBlueLight,
                              ),
                              onPressed: () {
                                isEditing = true;
                                updateState();
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: btnBlueDark,
                                size: 18,
                              ),
                              label: Text(
                                loc.editShot,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: btnBlueDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FullscreenImageViewer extends StatelessWidget {
  const FullscreenImageViewer({
    super.key,
    required this.imagePath,
    required this.title,
  });

  final String imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: photo_view_package.PhotoView(
        imageProvider: ResizeImage(
          FileImage(File(imagePath)),
          width: 1600,
          height: 1600,
          allowUpscaling: false,
        ),
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        minScale: photo_view_package.PhotoViewComputedScale.contained * 0.8,
        maxScale: photo_view_package.PhotoViewComputedScale.covered * 4.0,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder:
            (context, event) => Center(
              child: CircularProgressIndicator(
                value:
                    event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
              ),
            ),
      ),
    );
  }
}
