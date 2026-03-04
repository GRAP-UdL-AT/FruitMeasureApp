import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/find_photo_in_gallery.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

Future<List<PhotoComplete>> getPhotoComplete({
  required String measurementId,
  bool updateGalleryPaths = false,
}) async {
  final photos =
      Hive.box<Photo>(
        photoBoxName,
      ).values.where((p) => p.measurementId == measurementId).toList();

  final photoCompletes = <PhotoComplete>[];

  for (final p in photos) {
    String? galleryPathToUse = p.galleryPath;

    if (updateGalleryPaths) {
      final foundGalleryPath = await findPhotoInGallery(
        processedImagePath: p.imagePath,
        originalImagePath: p.originalImagePath,
      );
      if (foundGalleryPath != null) {
        galleryPathToUse = foundGalleryPath;
        p.galleryPath = foundGalleryPath;
        await Hive.box<Photo>(photoBoxName).put(p.id, p);
      }
    }

    photoCompletes.add(
      PhotoComplete(
        id: p.id,
        measurementId: p.measurementId,
        captureDate: p.captureDate,
        creationDate: p.creationDate,
        latitude: p.latitude,
        longitude: p.longitude,
        imagePath: p.imagePath,
        galleryPath: galleryPathToUse,
        originalImagePath: p.originalImagePath,
        detections:
            Hive.box<Detection>(
              detectionsBoxName,
            ).values.where((d) => d.photoId == p.id).toList(),
      ),
    );
  }

  return photoCompletes;
}
