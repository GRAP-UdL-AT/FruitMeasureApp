import 'dart:io';

import 'package:flutter/services.dart';

class GallerySaveResult {
  GallerySaveResult({
    this.localIdentifier,
    this.error,
    this.isPermissionError = false,
  });

  final String? localIdentifier;
  final String? error;
  final bool isPermissionError;

  bool get success => localIdentifier != null;
}

class GallerySaveChannel {
  static const String _channelName = 'com.fruitapp/gallery_save';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<GallerySaveResult> saveToGallery(String imagePath) async {
    try {
      if (Platform.isIOS) {
        final result = await _channel.invokeMethod<String>('saveToGallery', {
          'imagePath': imagePath,
        });

        if (result != null) {
          return GallerySaveResult(localIdentifier: result);
        } else {
          return GallerySaveResult(error: 'GALLERY_SAVE_FAILED');
        }
      }
      return GallerySaveResult(localIdentifier: null);
    } on PlatformException catch (e) {
      final isPermissionError =
          e.code == 'PERMISSION_DENIED' ||
          e.message?.contains('permission') == true ||
          e.message?.contains('authorized') == true;

      return GallerySaveResult(
        error: e.message ?? 'UNKNOWN_ERROR',
        isPermissionError: isPermissionError,
      );
    } catch (e) {
      return GallerySaveResult(error: e.toString());
    }
  }
}
