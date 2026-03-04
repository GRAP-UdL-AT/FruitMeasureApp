package com.anphis.es.fruit_measure_app

import android.content.ContentUris
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.anphis.es.fruit_measure_app/gallery"
    private val GALLERY_DELETE_CHANNEL = "com.fruitapp/gallery_delete"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "deleteFromGallery" -> {
                    val fileName = call.argument<String>("fileName")
                    if (fileName != null) {
                        val deleted = deleteImageFromGallery(fileName)
                        result.success(deleted)
                    } else {
                        result.error("INVALID_ARGUMENT", "fileName is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GALLERY_DELETE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "deleteFromMediaStore" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        try {
                            val handler = GalleryDeleteHandler(this)
                            val deleted = handler.deleteFromMediaStore(filePath)
                            result.success(deleted)
                        } catch (e: SecurityException) {
                            result.error("PERMISSION_DENIED", "Missing storage permissions", null)
                        } catch (e: Exception) {
                            result.error("DELETE_FAILED", "Failed to delete from MediaStore", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "filePath is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun deleteImageFromGallery(fileName: String): Boolean {
        try {
            val contentResolver = contentResolver
            val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }

            val projection = arrayOf(
                MediaStore.Images.Media._ID,
                MediaStore.Images.Media.DISPLAY_NAME
            )
            
            val selection = "${MediaStore.Images.Media.DISPLAY_NAME} = ?"
            val selectionArgs = arrayOf(fileName)

            val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

            contentResolver.query(
                collection,
                projection,
                selection,
                selectionArgs,
                sortOrder
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
                    val id = cursor.getLong(idColumn)
                    val contentUri = ContentUris.withAppendedId(collection, id)
                    val deleted = contentResolver.delete(contentUri, null, null)
                    return deleted > 0
                }
            }
            
            return false
        } catch (e: Exception) {
            return false
        }
    }
}
