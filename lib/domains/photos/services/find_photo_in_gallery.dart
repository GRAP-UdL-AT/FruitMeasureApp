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

    AssetEntity? matchedAsset;
    String? matchedFileName;

    for (final asset in assets) {
      final file = await asset.file;
      if (file == null) continue;

      final assetFileName = file.path.split('/').last;

      final matchesExpectedName =
          expectedProcessedFileName != null &&
          assetFileName == expectedProcessedFileName;

      final matchesLocalName =
          assetFileName == localFileName;

      if (!matchesExpectedName && !matchesLocalName) {
        continue;
      }

      if (matchedAsset != null && matchedAsset.id != asset.id) {
        // Ambiguous filename: do not return an uncertain ID.
        return null;
      }

      matchedAsset = asset;
      matchedFileName = assetFileName;
    }

    if (matchedAsset == null) return null;

    if (Platform.isIOS) {
      return matchedAsset.id;
    }

    return matchedFileName;


    return null;
  } catch (e) {
    return null;
  }
}
