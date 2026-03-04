package com.anphis.es.fruit_measure_app

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import java.io.File

class GalleryDeleteHandler(private val context: Context) {

    fun deleteFromMediaStore(filePath: String): Boolean {
        try {
            val file = File(filePath)
            val fileName = file.name
            val contentResolver: ContentResolver = context.contentResolver

            val collection: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }

            val imageUri = findImageInMediaStore(
                contentResolver,
                collection,
                fileName,
                filePath
            ) ?: return false

            val deletedRows = contentResolver.delete(imageUri, null, null)
            return deletedRows > 0

        } catch (e: Exception) {
            return false
        }
    }

    private fun findImageInMediaStore(
        contentResolver: ContentResolver,
        collection: Uri,
        fileName: String,
        filePath: String
    ): Uri? {
        val localFile = File(filePath)
        val localFileSize = if (localFile.exists()) localFile.length() else 0L

        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.DATA,
            MediaStore.Images.Media.SIZE,
            MediaStore.Images.Media.DATE_ADDED
        )

        val selectionByName = "${MediaStore.Images.Media.DISPLAY_NAME} = ?"
        val selectionArgsByName = arrayOf(fileName)

        var imageUri = queryMediaStore(
            contentResolver,
            collection,
            projection,
            selectionByName,
            selectionArgsByName
        )

        if (imageUri != null) return imageUri

        val timestampMatch = Regex("processed_image_(\\d+)\\.png").find(fileName)
        if (timestampMatch != null) {
            val timestamp = timestampMatch.groupValues[1]
            val selectionByPattern = "${MediaStore.Images.Media.DISPLAY_NAME} LIKE ?"
            val selectionArgsByPattern = arrayOf("%$timestamp%")

            imageUri = queryMediaStore(
                contentResolver,
                collection,
                projection,
                selectionByPattern,
                selectionArgsByPattern
            )

            if (imageUri != null) return imageUri
        }

        if (localFileSize > 0) {
            val oneDayAgo = (System.currentTimeMillis() / 1000) - (24 * 60 * 60)
            val selectionBySize = "${MediaStore.Images.Media.SIZE} = ? AND ${MediaStore.Images.Media.DATE_ADDED} > ?"
            val selectionArgsBySize = arrayOf(localFileSize.toString(), oneDayAgo.toString())

            imageUri = queryMediaStore(
                contentResolver,
                collection,
                projection,
                selectionBySize,
                selectionArgsBySize
            )

            if (imageUri != null) return imageUri
        }

        val selectionByPath = "${MediaStore.Images.Media.DATA} = ?"
        val selectionArgsByPath = arrayOf(filePath)

        return queryMediaStore(
            contentResolver,
            collection,
            projection,
            selectionByPath,
            selectionArgsByPath
        )
    }

    private fun queryMediaStore(
        contentResolver: ContentResolver,
        collection: Uri,
        projection: Array<String>,
        selection: String,
        selectionArgs: Array<String>
    ): Uri? {
        try {
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
                    return ContentUris.withAppendedId(collection, id)
                }
            }
        } catch (e: Exception) {
            return null
        }

        return null
    }
}
