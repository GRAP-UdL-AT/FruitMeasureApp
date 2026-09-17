import 'package:dartx/dartx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/model_enum.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/caixa_detection_processor.dart';
import 'package:fruit_measure_app/domains/photos/services/convert_modified_image_to_xfile.dart';
import 'package:fruit_measure_app/domains/photos/services/detection_annotation_renderer.dart';
import 'package:fruit_measure_app/domains/photos/services/extract_photo_datetime.dart';
import 'package:fruit_measure_app/domains/photos/services/process_image_for_model.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/domains/yolo/models/yolo_model.dart';
import 'package:fruit_measure_app/utils/get_current_location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

Future<List<(XFile, String?)>?> _pickMultipleImages(
  ImageSource takingType,
) async {
  if (takingType == ImageSource.gallery) {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return null;

    return result.files.map((file) => (file.xFile, file.name)).toList();
  }

  final picker = ImagePicker();

  final picked = await picker.pickImage(
    source: ImageSource.camera,
    maxWidth: kModelMaxImageSize.toDouble(),
    maxHeight: kModelMaxImageSize.toDouble(),
    imageQuality: 100,
  );

  if (picked == null) return null;

  return [(picked, picked.name)];
}

Future<List<(PhotoComplete, XFile, XFile, List<Detection>)>?>
takeAndProcessMultiplePhotos({
  required Measurement measurement,
  required ImageSource takingType,
  required double dist,
  required Function(int, int) onProgress,
}) async {
  final loc = await getCurrentLocation();
  final images = await _pickMultipleImages(takingType);

  if (images == null) {
    return null;
  }

  onProgress(0, images.length);

  await YoloModel.init(model: measurement.model ?? Model.fruto);

  final List<(PhotoComplete, XFile, XFile, List<Detection>)> results = [];

  for (int i = 0; i < images.length; i++) {
    onProgress(i + 1, images.length);

    final (pickedFile, originalFilename) = images[i];
    ProcessedImageForModel processed;
    try {
      processed = await processImageForModel(pickedFile);
    } catch (_) {
      continue;
    }
    final image = processed.image;
    final png = processed.png;

    final photoId = const Uuid().v4();

    DateTime captureDate;
    try {
      captureDate = await extractPhotoCaptureDateTime(pickedFile);
    } catch (_) {
      captureDate = DateTime.now();
    }
    final creationDate = DateTime.now();

    List<dynamic> res;
    try {
      res = await YoloModel.predict(png);
    } catch (e) {
      continue;
    }
    final boxes = res;

    if (boxes.isEmpty) continue;

    if (measurement.model == Model.caixa) {
      try {
        final result = await CaixaDetectionProcessor.process(
          rawDetections: boxes,
          image: image,
          photoId: photoId,
        );

        if (result.validFruits.isEmpty) {
          continue;
        }

        final sortedFruits =
            result.validFruits.toList()..sort((a, b) {
              final centerAX = (a.x1 + a.x2) / 2;
              final centerBX = (b.x1 + b.x2) / 2;
              return centerAX.compareTo(centerBX);
            });

        drawDetectionAnnotations(image: image, detections: sortedFruits);

        final complete = PhotoComplete(
          id: photoId,
          measurementId: measurement.id,
          captureDate: captureDate,
          creationDate: creationDate,
          latitude: loc?.latitude,
          longitude: loc?.longitude,
          imagePath: null,
          originalFilename: originalFilename,
          detections: sortedFruits,
        );

        final processedFile = await convertModifiedImageToXFile(
          image,
          originalFilename: originalFilename,
          uniqueId: photoId,
        );
        results.add((complete, pickedFile, processedFile, sortedFruits));
        continue;
      } on CaixaProcessingException {
        continue;
      }
    }

    Detection? support;
    var detections = <Detection>[];
    final threshold = currentUser?.confidenceThreshold ?? 0.80;

    for (final e in boxes) {
      if (e['confidence'] < threshold) continue;
      final d = Detection(
        id: const Uuid().v4(),
        photoId: photoId,
        confidence: e['confidence'],
        cls: e['className'],
        x1: e['x1'],
        y1: e['y1'],
        x2: e['x2'],
        y2: e['y2'],
        caliber: 0,
      );

      d.cls != 'peu_de_rei' ? (detections.add(d)) : (support ??= d);
    }

    if (support == null || detections.isEmpty) continue;

    final cX = image.width / 2;
    final cY = image.height / 2;

    if (measurement.model == Model.corimbo) {
      for (final d in detections) {
        d.caliber = d.diameterInMm(
          supportX1: support.x1,
          supportX2: support.x2,
          supportY1: support.y1,
          supportY2: support.y2,
        );
      }
      drawDetectionAnnotations(image: image, detections: detections);
    } else {
      final closest = detections.minBy(
        (d) => d.distanceFromImgCenter(cX: cX, cY: cY),
      );
      if (closest == null) continue;

      detections = detections.filter((d) => d.id == closest.id).toList();

      closest.caliber = closest.diameterInMm(
        supportX1: support.x1,
        supportX2: support.x2,
        supportY1: support.y1,
        supportY2: support.y2,
        distFruitToCamMm: dist,
      );

      drawDetectionAnnotations(image: image, detections: detections);
    }

    final complete = PhotoComplete(
      id: photoId,
      measurementId: measurement.id,
      captureDate: captureDate,
      creationDate: creationDate,
      latitude: loc?.latitude,
      longitude: loc?.longitude,
      imagePath: null,
      originalFilename: originalFilename,
      detections: detections,
    );

    final processedFile = await convertModifiedImageToXFile(
      image,
      originalFilename: originalFilename,
      uniqueId: photoId,
    );
    results.add((complete, pickedFile, processedFile, detections));
  }

  if (results.isEmpty) {
    throw Exception('No valid photos were processed');
  }

  return results;
}
