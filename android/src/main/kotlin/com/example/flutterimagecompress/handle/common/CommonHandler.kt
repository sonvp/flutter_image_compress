package com.example.flutterimagecompress.handle.common

import android.content.Context
import android.graphics.*
import com.example.flutterimagecompress.exif.ExifKeeper
import com.example.flutterimagecompress.ext.calcScale
import com.example.flutterimagecompress.ext.compress
import com.example.flutterimagecompress.ext.drawText
import com.example.flutterimagecompress.ext.rotate
import com.example.flutterimagecompress.handle.FormatHandler
import com.example.flutterimagecompress.logger.log
import java.io.ByteArrayOutputStream
import java.io.OutputStream


class CommonHandler(override val type: Int) : FormatHandler {

  override val typeName: String
    get() {
      return when (type) {
        1 -> "png"
        3 -> "webp"
        else -> "jpeg"
      }
    }

  private val bitmapFormat: Bitmap.CompressFormat
    get() {
      return when (type) {
        1 -> Bitmap.CompressFormat.PNG
        3 -> Bitmap.CompressFormat.WEBP
        else -> Bitmap.CompressFormat.JPEG
      }
    }

  override fun handleByteArray(context: Context, byteArray: ByteArray, outputStream: OutputStream, minWidth: Int, minHeight: Int, quality: Int, rotate: Int, keepExif: Boolean, inSampleSize: Int,textOptions: HashMap<*, *>) {
    val result = compress(context,byteArray, minWidth, minHeight, quality, rotate, inSampleSize, textOptions)

    if (keepExif && bitmapFormat == Bitmap.CompressFormat.JPEG) {
      val byteArrayOutputStream = ByteArrayOutputStream()
      byteArrayOutputStream.write(result)
      val resultStream = ExifKeeper(byteArray).writeToOutputStream(
              context,
              byteArrayOutputStream
      )
      outputStream.write(resultStream.toByteArray())
    } else {
      outputStream.write(result)
    }

  }

  private fun compress(context: Context,arr: ByteArray, minWidth: Int, minHeight: Int, quality: Int, rotate: Int = 0, inSampleSize: Int, textOptions: HashMap<*, *>): ByteArray {
    val options = BitmapFactory.Options()
    options.inJustDecodeBounds = false
    options.inPreferredConfig = Bitmap.Config.RGB_565
    options.inSampleSize = inSampleSize
    options.inMutable = true
    if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M) {
      @Suppress("DEPRECATION")
      options.inDither = true
    }

    val bitmap = BitmapFactory.decodeByteArray(arr, 0, arr.count(), options)

    bitmap.drawText(context,null,textOptions)

    val outputStream = ByteArrayOutputStream()

    val w = bitmap.width.toFloat()
    val h = bitmap.height.toFloat()

    log("src width = $w")
    log("src height = $h")

    val scale = bitmap.calcScale(minWidth, minHeight)

    log("scale = $scale")

    val destW = w / scale
    val destH = h / scale

    log("dst width = $destW")
    log("dst height = $destH")

    Bitmap.createScaledBitmap(bitmap, destW.toInt(), destH.toInt(), true)
            .rotate(rotate)
            .compress(bitmapFormat, quality, outputStream)

    return outputStream.toByteArray()
  }


  override fun handleFile(context: Context, path: String, outputStream: OutputStream, minWidth: Int, minHeight: Int, quality: Int, rotate: Int, keepExif: Boolean, inSampleSize: Int,numberOfRetries:Int, textOptions: HashMap<*, *>) {
    try{
      if(numberOfRetries <= 0)return;
      val options = BitmapFactory.Options()
      options.inJustDecodeBounds = false
      options.inPreferredConfig = Bitmap.Config.RGB_565
      options.inSampleSize = inSampleSize
      options.inMutable = true
      if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M) {
        @Suppress("DEPRECATION")
        options.inDither = true
      }
      val bitmap = BitmapFactory.decodeFile(path, options)

      bitmap.drawText(context,path,textOptions)

      val array = bitmap.compress(minWidth, minHeight, quality, rotate, type)

      if (keepExif && bitmapFormat == Bitmap.CompressFormat.JPEG) {
        val byteArrayOutputStream = ByteArrayOutputStream()
        byteArrayOutputStream.write(array)
        val tmpOutputStream = ExifKeeper(path).writeToOutputStream(
                context,
                byteArrayOutputStream
        )
        outputStream.write(tmpOutputStream.toByteArray())
      } else {
        outputStream.write(array)
      }
    }catch (e:OutOfMemoryError){//handling out of memory error and increase samples size
      System.gc();
      handleFile(context, path, outputStream, minWidth, minHeight, quality, rotate, keepExif, inSampleSize *2,numberOfRetries-1,textOptions);
    }
  }
}
