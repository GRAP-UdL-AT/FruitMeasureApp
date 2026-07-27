import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/domains/detections/services/edit_detection.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/edit_photo.dart';
import 'package:fruit_measure_app/domains/photos/services/take_and_process_multiple_photos.dart';
import 'package:fruit_measure_app/domains/photos/services/take_and_process_photo.dart';
import 'package:fruit_measure_app/domains/photos/views/photo_view.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/platforms/gallery_save_channel.dart';
import 'package:gal/gal.dart';
import 'package:hive_ce/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Measurement _getMeasurementById({required String measurementId}) {
  final Measurement m = Hive.box<Measurement>(
    measurementBoxName,
  ).values.firstWhere((measurement) => measurement.id == measurementId);

  return m;
}

String _basename(String path) {
  return path.split(RegExp(r'[/\\]')).last;
}

String _safeFilename(String filename) {
  return filename
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
      .replaceAll(RegExp(r'\s+'), '_');
}

String _basenameWithoutExtension(String filename) {
  final dotIndex = filename.lastIndexOf('.');
  if (dotIndex <= 0) return filename;
  return filename.substring(0, dotIndex);
}

String _extensionFromFilename(String filename, {String fallback = 'jpg'}) {
  final dotIndex = filename.lastIndexOf('.');
  if (dotIndex <= 0 || dotIndex == filename.length - 1) return fallback;
  return filename.substring(dotIndex + 1).toLowerCase();
}

String _processedFilenameFromPhoto({
  required Photo photo,
  required XFile processedImage,
}) {
  final sourceFilename = photo.sourceId;

  if (sourceFilename != null && sourceFilename.isNotEmpty) {
    final safeSource = _safeFilename(_basename(sourceFilename));
    final sourceBasename = _basenameWithoutExtension(safeSource);

    // La imatge processada es genera amb encodePng, per tant l'extensió correcta és .png
    return '${sourceBasename}_processed.png';
  }

  final processedName = processedImage.name;
  if (processedName.isNotEmpty) {
    return _safeFilename(_basename(processedName));
  }

  return _safeFilename(_basename(processedImage.path));
}

Future<void> _saveImage({
  required Photo photo,
  required XFile originalImage,
  required XFile processedImage,
}) async {
  if (currentUser!.deletePhotosAfterMeasure != true) {
    final String duplicateFilePath =
        (await getApplicationDocumentsDirectory()).path;

    final originalFileName = photo.sourceId != null && photo.sourceId!.isNotEmpty
        ? _safeFilename(_basename(photo.sourceId!))
        : _safeFilename(_basename(originalImage.path));

    final originalFileExtension = _extensionFromFilename(originalFileName);

    final originalSavedPath =
        '$duplicateFilePath/original_${photo.id}.$originalFileExtension';

    await originalImage.saveTo(originalSavedPath);
    photo.originalImagePath = originalSavedPath;

    final processedFileName = _processedFilenameFromPhoto(
      photo: photo,
      processedImage: processedImage,
    );

    final processedSavedPath = '$duplicateFilePath/$processedFileName';

    print('SAVE ORIGINAL SOURCE ID: ${photo.sourceId}');
    print('SAVE ORIGINAL FILE NAME: $originalFileName');
    print('SAVE PROCESSED XFILE NAME: ${processedImage.name}');
    print('SAVE PROCESSED FINAL NAME: $processedFileName');
    print('SAVE PROCESSED FINAL PATH: $processedSavedPath');

    await processedImage.saveTo(processedSavedPath);
    photo.imagePath = processedSavedPath;

    if (Platform.isIOS) {
      final result = await GallerySaveChannel.saveToGallery(processedSavedPath);
      if (result.success) {
        photo.galleryPath = result.localIdentifier;
      } else {
        photo.galleryPath = null;
        throw Exception(
          'GALLERY_SAVE_ERROR:${result.isPermissionError ? "PERMISSION" : "UNKNOWN"}:${result.error}',
        );
      }
    } else {
      try {
        await Gal.putImage(processedSavedPath);
        photo.galleryPath = processedFileName;
      } catch (e) {
        photo.galleryPath = null;
      }
    }
  }
}

Future<PhotoView?> executePhotoTakingWorkflow({
  required BuildContext context,

  required ImageSource takingType,
  required Function() updateState,
  required Function(bool) setProcessing,
  Function(int, int)? setProgress,
  required double distFruitToCamMm,
  Measurement? measurement,
  String? measurementId,
}) async {
  try {
    final Measurement m;

    measurement != null
        ? (m = measurement)
        : (measurementId != null
            ? (m = _getMeasurementById(measurementId: measurementId))
            : throw Exception('Missing required params!'));

    final loc = AppLocalizations.of(context)!;

    if (takingType == ImageSource.gallery) {
      setProcessing(true);
      if (setProgress != null) {
        setProgress(0, 1); // mensaje "Seleccionando imágenes…"
      }

      final results = await takeAndProcessMultiplePhotos(
        measurement: m,
        takingType: takingType,
        dist: distFruitToCamMm,
        onProgress: (current, total) {
          if (setProgress != null) {
            setProgress(current, total);
          }
        },
      );

      if (results == null) {
        // User cancelled
        setProcessing(false);
        return null;
      }

      for (final (photo, originalImage, processedImage, detections)
          in results) {
        await _saveImage(
          photo: photo,
          originalImage: originalImage,
          processedImage: processedImage,
        );

        for (final detection in detections) {
          editDetection(detection);
        }

        editPhoto(photo);
      }

      setProcessing(false);
      updateState();

      if (results.length == 1) {
        final (photo, originalImage, processedImage, detections) =
            results.first;

        final PhotoComplete photoComplete = PhotoComplete(
          id: photo.id,
          measurementId: photo.measurementId,
          captureDate: photo.captureDate,
          creationDate: photo.creationDate,
          latitude: photo.latitude,
          longitude: photo.longitude,
          imagePath: photo.imagePath,
          originalImagePath: photo.originalImagePath,
          galleryPath: photo.galleryPath,
          sourceId: photo.sourceId,
          detections: detections,
        );

        final arguments = PhotoViewArguments(
          photo: photoComplete,
          takenImage: processedImage,
          isCreatePhoto: true,
        );

        Navigator.of(
          context,
        ).popUntil((route) => route.settings.name != '/photo');

        await Navigator.of(context)
            .pushNamed('/photo', arguments: arguments)
            .then((value) => updateState());
      } else {
        customSnackBar(
          context: context,
          message: '${results.length} ${loc.photosProcessed}',
          type: SnackbarType.success,
        );
      }

      return null;
    } else {
      setProcessing(true);

      final result = await takeAndProcessPhoto(
        measurement: m,

        takingType: takingType,
        dist: distFruitToCamMm,
      );

      if (result == null) {
        // User cancelled
        setProcessing(false);
        return null;
      }

      final (newPhoto, originalImage, processedImage, detections) = result;

      setProcessing(false);

      await _saveImage(
        photo: newPhoto,
        originalImage: originalImage,
        processedImage: processedImage,
      );

      final PhotoComplete photo = PhotoComplete(
        id: newPhoto.id,
        measurementId: newPhoto.measurementId,
        captureDate: newPhoto.captureDate,
        creationDate: newPhoto.creationDate,
        latitude: newPhoto.latitude,
        longitude: newPhoto.longitude,
        imagePath: newPhoto.imagePath,
        originalImagePath: newPhoto.originalImagePath,
        galleryPath: newPhoto.galleryPath,
        sourceId: newPhoto.sourceId,
        detections: detections,
      );

      for (final detection in detections) {
        editDetection(detection);
      }

      editPhoto(newPhoto);

      updateState();

      final arguments = PhotoViewArguments(
        photo: photo,
        takenImage: processedImage,
        isCreatePhoto: true,
      );

      Navigator.of(
        context,
      ).popUntil((route) => route.settings.name != '/photo');

      await Navigator.of(context)
          .pushNamed('/photo', arguments: arguments)
          .then((value) => updateState());
    }
  } catch (e) {
    setProcessing(false);

    final loc = AppLocalizations.of(context)!;
    String errorMessage = e.toString();

    if (errorMessage.contains('No image selected')) {
      errorMessage = loc.errorNoImageSelected;
    } else if (errorMessage.contains('Invalid image data')) {
      errorMessage = loc.errorInvalidImageData;
    } else if (errorMessage.contains('No fruits detected')) {
      errorMessage = loc.errorNoFruitsDetected;
    } else if (errorMessage.contains('Support not found')) {
      errorMessage = loc.errorSupportNotFound;
    } else if (errorMessage.contains('No valid detections found') ||
        errorMessage.contains('No detections found')) {
      errorMessage = loc.errorNoValidDetections;
    } else if (errorMessage.contains('No valid photos')) {
      errorMessage = loc.errorNoValidPhotos;
    } else if (errorMessage.contains('Missing required params')) {
      errorMessage = loc.errorMissingParams;
    } else if (errorMessage.contains('GALLERY_SAVE_ERROR')) {
      if (errorMessage.contains('PERMISSION')) {
        errorMessage = loc.errorGallerySavePermissionDenied;
      } else {
        errorMessage = loc.errorGallerySaveFailed;
      }
    } else if (errorMessage.contains('UNKNOWN_ERROR')) {
      errorMessage = loc.errorUnknown;
    } else if (errorMessage.contains('YOLO_PREDICTION_ERROR')) {
      errorMessage = loc.errorYoloPredictionFailed;
    } else if (errorMessage.contains('FILE_WRITE_ERROR')) {
      errorMessage = loc.errorFileWriteFailed;
    } else if (errorMessage.contains('FILE_READ_ERROR')) {
      errorMessage = loc.errorFileReadFailed;
    } else if (errorMessage.contains('EXPORT_ERROR')) {
      errorMessage = loc.errorExportFailed;
    } else {
      errorMessage = loc.errorUnexpected;
    }

    customSnackBar(
      context: context,
      message: errorMessage,
      type: SnackbarType.error,
    );
  }
  return null;
}
