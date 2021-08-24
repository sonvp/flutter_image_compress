package com.example.flutterimagecompress.ext

import android.content.Context
import android.content.res.AssetManager
import android.graphics.*
import android.text.TextPaint
import com.example.flutterimagecompress.FlutterImageCompressPlugin
import com.example.flutterimagecompress.exif.ExifKeeper
import io.flutter.FlutterInjector
import java.io.ByteArrayOutputStream
import java.io.OutputStream
import kotlin.math.max
import kotlin.math.min

fun Bitmap.compress(minWidth: Int, minHeight: Int, quality: Int, rotate: Int = 0, format: Int): ByteArray {
  val outputStream = ByteArrayOutputStream()
  compress(minWidth, minHeight, quality, rotate, outputStream, format)
  return outputStream.toByteArray()
}

fun Bitmap.compress(minWidth: Int, minHeight: Int, quality: Int, rotate: Int = 0, outputStream: OutputStream, format: Int = 0) {
  val w = this.width.toFloat()
  val h = this.height.toFloat()
  
  log("src width = $w")
  log("src height = $h")
  
  val scale = calcScale(minWidth, minHeight)
  
  log("scale = $scale")
  
  val destW = w / scale
  val destH = h / scale
  
  log("dst width = $destW")
  log("dst height = $destH")
  
  Bitmap.createScaledBitmap(this, destW.toInt(), destH.toInt(), true)
    .rotate(rotate)
    .compress(convertFormatIndexToFormat(format), quality, outputStream)
}

private fun log(any: Any?) {
  if (FlutterImageCompressPlugin.showLog) {
    println(any ?: "null")
  }
}

fun Bitmap.rotate(rotate: Int): Bitmap {
  return if (rotate % 360 != 0) {
    val matrix = Matrix()
    matrix.setRotate(rotate.toFloat())
    // 围绕原地进行旋转
    Bitmap.createBitmap(this, 0, 0, width, height, matrix, false)
  } else {
    this
  }
}

fun Bitmap.calcScale(minWidth: Int, minHeight: Int): Float {
  val w = width.toFloat()
  val h = height.toFloat()
  
  val scaleW = w / minWidth.toFloat()
  val scaleH = h / minHeight.toFloat()
  
  log("width scale = $scaleW")
  log("height scale = $scaleH")
  
  return max(1f, min(scaleW, scaleH))
}

fun convertFormatIndexToFormat(type: Int): Bitmap.CompressFormat {
  return if (type == 1) Bitmap.CompressFormat.PNG else if (type == 3) Bitmap.CompressFormat.WEBP else Bitmap.CompressFormat.JPEG 
}


fun Bitmap.drawText(context: Context,path: String, textOptions: HashMap<*, *>) {

  val text: String? = textOptions["text"] as String?
  val color: String? = textOptions["color"] as String?
  val size: String? = textOptions["size"] as String?
  val margin: String? = textOptions["margin"] as String?
  val fontPath: String? = textOptions["fontPath"] as String?
  val alignment: HashMap<*, *>? = textOptions["alignment"] as HashMap<*, *>?
  val x: Double = alignment?.get("x") as Double? ?: (-1).toDouble()
  val y: Double = alignment?.get("y") as Double? ?: (-1).toDouble()

  if (!text.isNullOrEmpty()) {
    val rotate = ExifKeeper(path).cameraPhotoOrientation
    val canvas = Canvas(this)
    canvas.rotate(-rotate)
    val textPaint = TextPaint()
    val bounds = Rect()

    //Add font
    if (!fontPath.isNullOrEmpty()) {
      val loader = FlutterInjector.instance().flutterLoader()
      val fontKey = loader.getLookupKeyForAsset(fontPath)
      val assetManager: AssetManager = context.assets
      val myTypeface = Typeface.createFromAsset(assetManager, fontKey)
      textPaint.typeface = myTypeface
    }

    textPaint.style = Paint.Style.FILL
    textPaint.color = if (!color.isNullOrEmpty()) Color.parseColor(color) else Color.BLACK
    textPaint.textSize = if (!size.isNullOrEmpty()) size.toFloat() else 100f
    textPaint.getTextBounds(text, 0, text.length, bounds)

    canvas.drawText(text, xPos(canvas, rotate, bounds, x.toFloat(), margin!!.toFloat()), yPos(canvas, rotate, textPaint, y.toFloat(), margin.toFloat()), textPaint)
  }
}

  val LENGTH = 2

  fun xPos(canvas: Canvas, rotate: Float, rect : Rect, x: Float, marginText: Float): Float {
  val margin = marginText(x, marginText)

  return when (rotate) {
    90.0f -> {
      val length = (canvas.height.toFloat() - (rect.width().toFloat())) / 2
      -(((LENGTH -(LENGTH + x - 1)) * length) + rect.width().toFloat()) + margin
    }
    180.0f -> {
      val length = (canvas.width.toFloat() - (rect.width().toFloat())) / 2
      -(((LENGTH -(LENGTH + x - 1)) * length) + rect.width().toFloat()) + margin
    }
    270.0f -> {
      val length = (canvas.height.toFloat() - (rect.width().toFloat())) / 2
      canvas.height.toFloat() - (((LENGTH -(LENGTH + x - 1)) * length) + rect.width().toFloat()) + margin
    }
    else -> { // Note the block
      val length = (canvas.width.toFloat() - (rect.width().toFloat())) / 2
      canvas.width.toFloat() - (((LENGTH -(LENGTH + x - 1)) * length) + rect.width().toFloat()) + margin
    }
  }
}

  fun marginText(x: Float, marginText: Float): Float {
    return when {
      x < 0.0f -> {
        marginText
      }
      x > 0.0f -> {
        -marginText
      }
      else -> {
        0.0f
      }
    }
  }

 fun yPos(canvas: Canvas, rotate: Float, textPaint: TextPaint, y: Float, marginText: Float): Float {
  val margin = marginText(y,marginText)

  return when (rotate) {
    0.0f-> { // Note the block
      val length = (canvas.height.toFloat() - ((- (textPaint.descent() + textPaint.ascent())))) / 2
      (LENGTH + y - 1) * length - (textPaint.descent() + textPaint.ascent()) + margin
    }
    180.0f ->{
      val length = (canvas.height.toFloat() - (-(textPaint.descent() + textPaint.ascent()))) / 2
      (LENGTH + y - 1) * length - canvas.height.toFloat() - (textPaint.descent() + textPaint.ascent()) + margin
    }
    270.0f -> {
      val length = (canvas.width.toFloat() - (-(textPaint.descent() + textPaint.ascent()))) / 2
      (LENGTH + y - 1) * length - canvas.width.toFloat() - (textPaint.descent() + textPaint.ascent()) + margin
    }
    else -> { // Note the block
      val length = (canvas.width.toFloat() - (- (textPaint.descent() + textPaint.ascent()))) / 2
      ((((LENGTH + y - 1)) * length) + (- (textPaint.descent() + textPaint.ascent()))) + margin
    }
  }
}