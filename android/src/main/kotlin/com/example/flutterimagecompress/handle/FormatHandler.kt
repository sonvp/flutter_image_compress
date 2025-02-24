package com.example.flutterimagecompress.handle

import android.content.Context
import java.io.OutputStream

interface FormatHandler {

  val type: Int

  val typeName: String

  fun handleByteArray(context: Context, byteArray: ByteArray, outputStream: OutputStream, minWidth: Int, minHeight: Int, quality: Int, rotate: Int, keepExif: Boolean, inSampleSize: Int, textOptions: HashMap<*, *>)

  fun handleFile(context: Context, path: String, outputStream: OutputStream, minWidth: Int, minHeight: Int, quality: Int, rotate: Int, keepExif: Boolean, inSampleSize: Int,numberOfRetries:Int, textOptions: HashMap<*, *>)
}