import 'package:flutter/services.dart';

class GalleryDeleteResult {
  GalleryDeleteResult({
    required this.success,
    this.error,
    this.isPermissionError = false,
  });

  final bool success;
  final String? error;
  final bool isPermissionError;
}

class GalleryDeleteChannel {
  static const String _channelName = 'com.fruitapp/gallery_delete';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<GalleryDeleteResult> deleteFromMediaStore(
    String filePath,
  ) async {
    try {
      final result = await _channel.invokeMethod<bool>('deleteFromMediaStore', {
        'filePath': filePath,
      });

      return GalleryDeleteResult(success: result ?? false);
    } on PlatformException catch (e) {
      final isPermissionError =
          e.code == 'PERMISSION_DENIED' ||
          e.message?.contains('permission') == true ||
          e.message?.contains('authorized') == true;

      return GalleryDeleteResult(
        success: false,
        error: e.message ?? 'UNKNOWN_ERROR',
        isPermissionError: isPermissionError,
      );
    } catch (e) {
      return GalleryDeleteResult(success: false, error: e.toString());
    }
  }

  /// Batch removal on iOS: one native PhotoKit transaction and confirmation.
  /// Each item can contain a galleryPath (PHAsset local identifier) and/or
  /// imagePath (legacy fallback). Does not attempt per-photo retries.
  static Future<GalleryDeleteResult> deleteManyFromMediaStore(
    List<Map<String, String>> photos,
  ) async {
    if (photos.isEmpty) return GalleryDeleteResult(success: true);

    try {
      final result = await _channel.invokeMethod<bool>(
        'deleteManyFromMediaStore',
        {'photos': photos},
      );
      return GalleryDeleteResult(success: result ?? false);
    } on PlatformException catch (e) {
      return GalleryDeleteResult(
        success: false,
        error: e.message ?? e.code,
        isPermissionError: e.code == 'PERMISSION_DENIED',
      );
    } catch (e) {
      return GalleryDeleteResult(success: false, error: e.toString());
    }
  }

}
