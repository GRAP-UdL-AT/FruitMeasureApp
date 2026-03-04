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
