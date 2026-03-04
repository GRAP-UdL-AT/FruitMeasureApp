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
}
