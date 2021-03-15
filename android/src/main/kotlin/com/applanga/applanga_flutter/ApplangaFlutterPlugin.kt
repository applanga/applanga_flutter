package com.applanga.applanga_flutter

import android.app.Activity
import android.graphics.Bitmap
import android.os.Debug
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import androidx.annotation.NonNull
import androidx.annotation.UiThread
import com.applanga.android.Applanga
import com.applanga.android.ApplangaScreenshotInterface
import com.applanga.android.ApplangaScreenshotInterface.StringPositionsCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.FlutterView
import java.util.*

/** ApplangaFlutterPlugin */
class ApplangaFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var theActivity: Activity? = null
  private var mainFlutterView: Any? = null

  companion object {
    fun dispatchTouchEvent(ev: MotionEvent?, a: Activity?) {
      Applanga.dispatchTouchEvent(ev, a)
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "applanga_flutter")
    channel.setMethodCallHandler(this)
    Applanga.init(flutterPluginBinding.applicationContext)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    theActivity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    theActivity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    theActivity = binding.activity
  }

  override fun onDetachedFromActivity() {
    theActivity = null
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun getTheScreenshot(): Bitmap? {
    Log.println(Log.INFO, "APPLANGA", "get the bitmap")
    try {
      val rootView: View? = theActivity?.window?.decorView?.rootView
      val theGroup = rootView as ViewGroup
      FindTheFlutterView(theGroup)
      var bitmap: Bitmap? = null
      if (mainFlutterView is FlutterView) {
        Log.println(Log.INFO, "APPLANGA", "get the bitmap old flutter view")
        bitmap = (mainFlutterView as FlutterView).bitmap
      } else if (mainFlutterView is io.flutter.embedding.android.FlutterView) {
        Log.println(Log.INFO, "APPLANGA", "get the bitmap new flutter view")
        val theView = mainFlutterView as io.flutter.embedding.android.FlutterView
        theView.buildDrawingCache()
        bitmap = theView.drawingCache
      }
      mainFlutterView = null
      Log.println(Log.INFO, "APPLANGA", "returning flutter view")
      return bitmap
    } catch (ex: Exception) {
      Log.println(Log.INFO, "APPLANGA", "Error taking screenshot: " + ex.message)
    }
    return null
  }

  private fun FindTheFlutterView(viewGroup: ViewGroup) {
    for (i in 0 until viewGroup.childCount) {
      val child = viewGroup.getChildAt(i) as View
      //      Log.println(Log.INFO, "APPLANGA", "CLASSNAME: " + child.getClass().getSimpleName());
      if (child.javaClass.simpleName == "FlutterView") {
        mainFlutterView = child
        break
      }
      if (child is ViewGroup) {
        FindTheFlutterView(child)
      }
    }
  }


  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    Log.d("onMethodCall", "name = " + call.method);
    if (call.method == "getString") {
      val key = call.argument<String>("key")
      val defaultValue = call.argument<String>("defaultValue")
      Log.d("applanga", "calling get string with key: $key and default value: $defaultValue")
      result.success(Applanga.getString(key, defaultValue))
    } else if (call.method == "takeScreenshotWithTag") {
      val tag = call.argument<String>("tag")
      val useOcr = call.argument<Boolean>("useOcr")
      val stringIds = call.argument<List<String>>("stringIds")!!
      Applanga.captureScreenshot(tag, stringIds, useOcr!!) { aBoolean ->
        theActivity?.runOnUiThread(Runnable { result.success(aBoolean) })
      }
    } else if (call.method == "setlanguage") {
      val lang = call.argument<String>("lang")
      Applanga.setLanguage(lang)
      result.success(null)
    } else if (call.method == "localizedStringsForCurrentLanguage") {
      val translations: Map<String, String> = Applanga.localizedStringsForCurrentLanguage()
      result.success(translations)
    } else if (call.method == "update") {
      Applanga.update { b ->
        Log.d("applanga", String.format("onLocalizeFinished(%b)", b))
        theActivity?.runOnUiThread(Runnable { result.success(b) })
      }
      Applanga.setScreenshotInterface(object : ApplangaScreenshotInterface {
        override fun getScreenshot(): Bitmap {
          return getTheScreenshot()!!
        }

        override fun getStringPositions(callback: StringPositionsCallback) {
          Log.d("applanga", "foo")
          channel.invokeMethod("getStringPositions", null, object : Result {
            @UiThread
            override fun success(result: Any?) {
              Log.d("applanga", "foo1")
              callback.finish(result as String?)
            }

            @UiThread
            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
              Log.d("applanga", "foo2")
              callback.finish(null)
            }

            @UiThread
            override fun notImplemented() {
              Log.d("applanga", "foo3")
              callback.finish(null)
            }
          })
        }
      })
    } else if (call.method == "localizeMap") {
      val map: HashMap<String, HashMap<String, String>> = if (call.arguments is HashMap<*, *>) call.arguments as HashMap<String, HashMap<String, String>> else HashMap()
      val applangaMap = Applanga.localizeMap(map)
      result.success(applangaMap)
    } else if (call.method == "isDebuggerConnected") {
      result.success(Debug.isDebuggerConnected())
    } else if (call.method == "setLanguage") {
      result.success(Applanga.setLanguage(call.arguments.toString()))
    } else if (call.method == "showDraftModeDialog") {
      if (theActivity != null) {
        Applanga.showDraftModeDialog(theActivity)
        result.success(null)
      } else {
        result.error("DraftModeDialog", "Activity not found?", null)
      }
    } else if (call.method == "showScreenShotMenu") {
      Applanga.setScreenShotMenuVisible(true)
      result.success(null)
    } else if (call.method == "hideScreenShotMenu") {
      Applanga.setScreenShotMenuVisible(false)
      result.success(null)
    } else {
      result.notImplemented()
    }
  }



}
