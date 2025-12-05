package com.rusticgram.app

import android.content.Context
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import android.app.NotificationManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL_DOWNLOAD = "download_image"

    override fun onResume() {
        super.onResume()
        closeAllNotifications()
    }

    private fun closeAllNotifications() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_DOWNLOAD).setMethodCallHandler { call, result ->
            if (call.method == "download_image") {
                val imageBytes = call.argument<ByteArray>("imageBytes")
                val watermarkPath = call.argument<String>("watermarkPath")

                if (imageBytes != null && watermarkPath != null) {
                    val processedBytes = processImageBytesWithWatermark(imageBytes, watermarkPath)
                    if (processedBytes != null) {
                        result.success(processedBytes)
                    } else {
                        result.success(byteArrayOf()) // Return empty array on failure
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Image bytes and Watermark Path are required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // Add watermark to provided image bytes and return the processed bytes
    private fun processImageBytesWithWatermark(imageBytes: ByteArray, watermarkPath: String): ByteArray? {
        return try {
            val watermarkBitmap = android.graphics.BitmapFactory.decodeFile(watermarkPath)
            val imageBitmap = android.graphics.BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

            if (watermarkBitmap == null || imageBitmap == null) {
                Log.e("MainActivity", "Failed to decode watermark or image bitmap")
                return null
            }

            val resultBitmap = android.graphics.Bitmap.createBitmap(
                imageBitmap.width,
                imageBitmap.height,
                imageBitmap.config ?: android.graphics.Bitmap.Config.ARGB_8888
            )
            val canvas = android.graphics.Canvas(resultBitmap)
            canvas.drawBitmap(imageBitmap, 0f, 0f, null)

            val transparencyLevel = 200
            val margin = 20f

            val targetWatermarkWidth = imageBitmap.width * 0.2f
            val scaleFactor = targetWatermarkWidth / watermarkBitmap.width

            val watermarkWidth = (watermarkBitmap.width * scaleFactor).toInt()
            val watermarkHeight = (watermarkBitmap.height * scaleFactor).toInt()

            val scaledWatermark = android.graphics.Bitmap.createScaledBitmap(
                watermarkBitmap,
                watermarkWidth,
                watermarkHeight,
                false
            )

            val xPos = (imageBitmap.width - watermarkWidth - margin).toInt()
            val yPos = (imageBitmap.height - watermarkHeight - margin).toInt()

            val paint = android.graphics.Paint().apply {
                alpha = transparencyLevel
            }

            canvas.drawBitmap(scaledWatermark, xPos.toFloat(), yPos.toFloat(), paint)

            val outputStream = ByteArrayOutputStream()
            resultBitmap.compress(android.graphics.Bitmap.CompressFormat.JPEG, 100, outputStream)
            outputStream.toByteArray()
        } catch (e: Exception) {
            Log.e("MainActivity", "Error processing image bytes: ${e.message}")
            null
        }
    }
}
