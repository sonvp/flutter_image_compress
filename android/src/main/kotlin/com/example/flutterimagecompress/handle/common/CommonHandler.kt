package com.example.flutterimagecompress.handle.common

import android.content.Context
import android.graphics.*
import android.text.TextPaint
import com.example.flutterimagecompress.exif.ExifKeeper
import com.example.flutterimagecompress.ext.calcScale
import com.example.flutterimagecompress.ext.compress
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

  override fun handleByteArray(context: Context, byteArray: ByteArray, outputStream: OutputStream, minWidth: Int, minHeight: Int, quality: Int, rotate: Int, keepExif: Boolean, inSampleSize: Int) {
    val result = compress(byteArray, minWidth, minHeight, quality, rotate, inSampleSize)

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

  private fun compress(arr: ByteArray, minWidth: Int, minHeight: Int, quality: Int, rotate: Int = 0, inSampleSize: Int): ByteArray {
    val options = BitmapFactory.Options()
    options.inJustDecodeBounds = false
    options.inPreferredConfig = Bitmap.Config.RGB_565
    options.inSampleSize = inSampleSize
    if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M) {
      @Suppress("DEPRECATION")
      options.inDither = true
    }

    val bitmap = BitmapFactory.decodeByteArray(arr, 0, arr.count(), options)
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
      options.inMutable=true
      if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M) {
        @Suppress("DEPRECATION")
        options.inDither = true
      }



      val bitmap = BitmapFactory.decodeFile(path, options)

      val text: String? = textOptions["text"] as String?
      val color: String? = textOptions["color"] as String?
      val size: String? = textOptions["size"] as String?
      val alignment: HashMap<*, *>? = textOptions["alignment"] as HashMap<*, *>?
      val x: Double = alignment?.get("x") as Double? ?: (-1).toDouble()
      val y: Double = alignment?.get("y") as Double? ?: (-1).toDouble()

      if (!text.isNullOrEmpty()) {
        val rotate = ExifKeeper(path).cameraPhotoOrientation
        val canvas = Canvas(bitmap)
        canvas.rotate(-rotate)
        val textPaint = TextPaint()
        val bounds = Rect()



        textPaint.style = Paint.Style.FILL
        textPaint.color = if (!color.isNullOrEmpty()) Color.parseColor(color) else Color.YELLOW
        textPaint.textSize =  if (!size.isNullOrEmpty()) size.toFloat() else 300f
        textPaint.getTextBounds(text, 0, text.length, bounds)

        canvas.drawText(text, xPos(canvas,rotate, bounds,x.toFloat()), yPos(canvas,rotate, textPaint,y.toFloat()), textPaint)
      }

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

  val LENGTH = 2
  val PADDING_RIGHT = 12;

  private fun xPos(canvas: Canvas, rotate: Float,rect :Rect,x: Float): Float {
    return when (rotate) {
      90.0f -> {
        val length = (canvas.height.toFloat() - (rect.width().toFloat()+PADDING_RIGHT)) / 2
        -(((LENGTH -(LENGTH + x - 1)) * length) + rect.width().toFloat()+PADDING_RIGHT)
      }
      180.0f -> {
        val length = (canvas.width.toFloat() - (rect.width().toFloat()+PADDING_RIGHT)) / 2
        -(((LENGTH -(LENGTH + x - 1)) * length) + rect.width().toFloat()+PADDING_RIGHT)
      }
      270.0f -> {
        val length = (canvas.height.toFloat() - (rect.width().toFloat()+PADDING_RIGHT)) / 2
        canvas.height.toFloat() - (((LENGTH -(LENGTH + x - 1)) * length) + rect.width().toFloat()+PADDING_RIGHT)
      }
      else -> { // Note the block
        val length = (canvas.width.toFloat() - (rect.width().toFloat()+PADDING_RIGHT)) / 2
        canvas.width.toFloat() - (((LENGTH -(LENGTH + x - 1)) * length) + rect.width().toFloat()+PADDING_RIGHT)
      }
    }
  }

  private fun yPos(canvas: Canvas, rotate: Float, textPaint:TextPaint,y: Float): Float {
    return when (rotate) {
      0.0f-> { // Note the block
        val length = (canvas.height.toFloat() - ((- (textPaint.descent() + textPaint.ascent())))) / 2
        (LENGTH + y - 1) * length - (textPaint.descent() + textPaint.ascent())
      }
      180.0f ->{
//        -canvas.height.toFloat() - (textPaint.descent() + textPaint.ascent())
        val length = (canvas.height.toFloat() - (-(textPaint.descent() + textPaint.ascent()))) / 2
        (LENGTH + y - 1) * length - canvas.height.toFloat() - (textPaint.descent() + textPaint.ascent())
      }
      270.0f -> {
//        -canvas.width.toFloat() - (textPaint.descent() + textPaint.ascent())
        val length = (canvas.width.toFloat() - (-(textPaint.descent() + textPaint.ascent()))) / 2
        (LENGTH + y - 1) * length - canvas.width.toFloat() - (textPaint.descent() + textPaint.ascent())
      }
      else -> { // Note the block
//        canvas.width.toFloat()
//        - (textPaint.descent() + textPaint.ascent())
        val length = (canvas.width.toFloat() - (- (textPaint.descent() + textPaint.ascent()))) / 2
        ((((LENGTH + y - 1)) * length) + (- (textPaint.descent() + textPaint.ascent())))
      }
    }
  }
}
