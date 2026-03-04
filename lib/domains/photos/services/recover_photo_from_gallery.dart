import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

Future<String?> recoverPhotoFromGallery({
  required String? galleryPath,
  String? originalFileName,
  PermissionState? permissionState,
}) async {
  if (galleryPath == null || galleryPath.isEmpty) {
    return null;
  }

  try {
    PermissionState ps;
    if (permissionState != null) {
      ps = permissionState;
    } else {
      ps = await PhotoManager.requestPermissionExtend().timeout(
        const Duration(seconds: 10),
      );
    }

    if (!ps.hasAccess) {
      return null;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    ).timeout(const Duration(seconds: 10));

    if (albums.isEmpty) {
      return null;
    }

    for (final album in albums) {
      final assetCount = await album.assetCountAsync;
      final assets = await album
          .getAssetListRange(start: 0, end: assetCount)
          .timeout(const Duration(seconds: 30));

      for (final asset in assets) {
        bool isMatch = false;

        if (Platform.isIOS) {
          isMatch = asset.id == galleryPath;
        } else {
          final file = await asset.file;
          if (file != null) {
            final assetFileName = file.path.split('/').last;
            isMatch =
                assetFileName == galleryPath ||
                (originalFileName != null && assetFileName == originalFileName);
          }
        }

        if (isMatch) {
          final file = await asset.file;
          if (file == null) {
            continue;
          }

          final documentsDir = await getApplicationDocumentsDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = galleryPath.split('/').last;
          final recoveredPath =
              '${documentsDir.path}/recovered_${timestamp}_$fileName';

          await file.copy(recoveredPath);

          return recoveredPath;
        }
      }
    }

    return null;
  } catch (e) {
    return null;
  }
}
