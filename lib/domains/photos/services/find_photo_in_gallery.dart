import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

Future<String?> findPhotoInGallery({
  String? processedImagePath,
  String? originalImagePath,
}) async {
  final pathToSearch = processedImagePath ?? originalImagePath;
  if (pathToSearch == null || pathToSearch.isEmpty) return null;

  try {
    final localFile = File(pathToSearch);
    if (!await localFile.exists()) return null;

    final localFileSize = await localFile.length();
    final localFileName = localFile.path.split('/').last;

    String? expectedProcessedFileName;
    if (processedImagePath != null) {
      expectedProcessedFileName = processedImagePath.split('/').last;
    } else if (originalImagePath != null) {
      final originalFileName = originalImagePath.split('/').last;
      if (originalFileName.startsWith('original_')) {
        expectedProcessedFileName =
            'processed_${originalFileName.substring('original_'.length)}';
      }
    }

    final ps = await PhotoManager.requestPermissionExtend().timeout(
      const Duration(seconds: 10),
    );

    if (!ps.hasAccess) return null;

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    ).timeout(const Duration(seconds: 5));

    if (albums.isEmpty) return null;

    final album = albums.first;
    final assetCount = await album.assetCountAsync;

    final searchLimit = assetCount > 200 ? 200 : assetCount;
    final assets = await album
        .getAssetListRange(start: 0, end: searchLimit)
        .timeout(const Duration(seconds: 10));

    for (final asset in assets) {
      final file = await asset.file;
      if (file != null) {
        final assetFileName = file.path.split('/').last;
        final assetSize = await file.length();

        if (expectedProcessedFileName != null &&
            assetFileName == expectedProcessedFileName) {
          if (Platform.isIOS) {
            return asset.id;
          } else {
            return assetFileName;
          }
        }

        if (assetFileName == localFileName) {
          if (Platform.isIOS) {
            return asset.id;
          } else {
            return assetFileName;
          }
        }

        if (assetSize == localFileSize) {
          if (Platform.isIOS) {
            return asset.id;
          } else {
            return assetFileName;
          }
        }
      }
    }

    return null;
  } catch (e) {
    return null;
  }
}
