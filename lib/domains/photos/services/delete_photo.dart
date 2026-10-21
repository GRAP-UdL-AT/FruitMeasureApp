import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/platforms/gallery_delete_channel.dart';
import 'package:hive_ce/hive.dart';
import 'package:photo_manager/photo_manager.dart';

Future<void> _deletePhysicalFile(String? imagePath) async {
  if (imagePath == null || imagePath.isEmpty) return;

  try {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to delete physical file: $e');
    }
  }
}

Future<void> _deleteFromGallery(String? imagePath, String? galleryPath) async {
  try {
    if (galleryPath != null && galleryPath.isNotEmpty) {
      final result = await _deleteFromGalleryNative(galleryPath);
      if (result.success) {
        return;
      }
    }

    if (imagePath != null && imagePath.isNotEmpty) {
      final result = await _deleteFromGalleryNative(imagePath);
      if (result.success) {
        return;
      }

      await _deleteFromGalleryPhotoManager(imagePath);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to delete from gallery: $e');
    }
  }
}

Future<GalleryDeleteResult> _deleteFromGalleryNative(String imagePath) async {
  return GalleryDeleteChannel.deleteFromMediaStore(imagePath);
}

Future<void> _deleteFromGalleryPhotoManager(String imagePath) async {
  try {
    final localFile = File(imagePath);
    if (!await localFile.exists()) return;

    final localFileSize = await localFile.length();
    final localFileName = localFile.path.split('/').last;

    final ps = await PhotoManager.requestPermissionExtend().timeout(
      const Duration(seconds: 10),
    );

    if (!ps.isAuth) return;

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    ).timeout(const Duration(seconds: 10));

    if (albums.isEmpty) return;

    final album = albums.first;
    final assetCount = await album.assetCountAsync;
    final assets = await album
        .getAssetListRange(start: 0, end: assetCount)
        .timeout(const Duration(seconds: 30));

    AssetEntity? targetAsset;

    for (final asset in assets) {
      final file = await asset.file;
      if (file != null) {
        final assetFileName = file.path.split('/').last;
        final assetSize = await file.length();

        if (assetFileName == localFileName) {
          targetAsset = asset;
          break;
        }

        if (assetSize == localFileSize && targetAsset == null) {
          targetAsset = asset;
        }
      }
    }

    if (targetAsset != null) {
      await PhotoManager.editor
          .deleteWithIds([targetAsset.id])
          .timeout(const Duration(seconds: 15));
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to delete from gallery via PhotoManager: $e');
    }
  }
}

Future<void> deletePhoto(
  String photoId, {
  bool deleteFromGallery = true,
}) async {
  final photoBox = Hive.box<Photo>(photoBoxName);
  final photo = photoBox.get(photoId);

  if (photo == null) return;

  final imagePath = photo.imagePath;
  final galleryPath = photo.galleryPath;
  final originalImagePath = photo.originalImagePath;

  if (deleteFromGallery) {
    await _deleteFromGallery(imagePath, galleryPath);
  }

  await _deletePhysicalFile(imagePath);
  await _deletePhysicalFile(originalImagePath);

  await photoBox.delete(photoId);
}


/// Delete multiple photos as one logical operation.
///
/// On iOS, requests deletion of all gallery assets in ONE PhotoKit transaction
/// (one system confirmation), then removes local files/Hive records. On Android
/// the existing individual deletion behavior is preserved.
Future<void> deletePhotos(
  Iterable<String> photoIds, {
  bool deleteFromGallery = true,
}) async {
  final box = Hive.box<Photo>(photoBoxName);
  final ids = photoIds.toSet();
  final photos = [
    for (final id in ids)
      if (box.get(id) case final Photo photo) photo,
  ];

  if (Platform.isIOS && deleteFromGallery) {
    final targets = <Map<String, String>>[];
    for (final photo in photos) {
      final target = <String, String>{};
      if (photo.galleryPath case final String path when path.isNotEmpty) {
        target['galleryPath'] = path;
      }
      if (photo.imagePath case final String path when path.isNotEmpty) {
        target['imagePath'] = path;
      }
      if (target.isNotEmpty) targets.add(target);
    }

    if (targets.isNotEmpty) {
      final result = await GalleryDeleteChannel.deleteManyFromMediaStore(
        targets,
      );
      if (!result.success && kDebugMode) {
        debugPrint(
          'Batch gallery deletion incomplete: ${result.error ?? "some assets were not found or deletion was declined"}',
        );
      }
    }

    // No further individual gallery calls: that would open more iOS prompts.
    for (final photo in photos) {
      await deletePhoto(photo.id, deleteFromGallery: false);
    }
  } else {
    for (final photo in photos) {
      await deletePhoto(photo.id, deleteFromGallery: deleteFromGallery);
    }
  }
}
