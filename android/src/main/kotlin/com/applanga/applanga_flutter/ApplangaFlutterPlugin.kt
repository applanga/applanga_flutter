package com.applanga.applanga_flutter

import android.app.Activity
import android.graphics.Bitmap
import android.os.Debug
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import com.applanga.android.Applanga
import com.applanga.android.ApplangaScreenshotInterface
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
class ApplangaFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel

    private var theActivity: Activity? = null
    private var mainFlutterView: Any? = null

    companion object {
        fun dispatchTouchEvent(ev: MotionEvent?, a: Activity?) {
            Applanga.dispatchTouchEvent(ev, a)
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
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

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun getTheScreenshot(): Bitmap? {
        try {
            val rootView: View? = theActivity?.window?.decorView?.rootView
            val theGroup = rootView as ViewGroup
            findTheFlutterView(theGroup)
            var bitmap: Bitmap? = null
            if (mainFlutterView is FlutterView) {
                bitmap = (mainFlutterView as FlutterView).bitmap
            } else if (mainFlutterView is io.flutter.embedding.android.FlutterView) {
                val theView = mainFlutterView as io.flutter.embedding.android.FlutterView
                theView.buildDrawingCache()
                bitmap = theView.drawingCache
            }
            mainFlutterView = null
            return bitmap
        } catch (ex: Exception) {
            Log.println(Log.ERROR, "APPLANGA", "Error taking screenshot: " + ex.message)
        }
        return null
    }

    private fun findTheFlutterView(viewGroup: ViewGroup) {
        for (i in 0 until viewGroup.childCount) {
            val child = viewGroup.getChildAt(i) as View
            //      Log.println(Log.INFO, "APPLANGA", "CLASSNAME: " + child.getClass().getSimpleName());
            if (child.javaClass.simpleName == "FlutterView") {
                mainFlutterView = child
                break
            }
            if (child is ViewGroup) {
                findTheFlutterView(child)
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "init") {
            Applanga.setScreenshotInterface(object : ApplangaScreenshotInterface {
                override fun onCaptureScreenshotFromOverlay(screenTag: String){
                    channel.invokeMethod("captureScreenshotFromOverlay", screenTag)
                }
                override fun getScreenshot(): Bitmap {
                    return getTheScreenshot()!!
                }
            })
        } else if(call.method == "setShowIdModeEnabled"){
            val enabled = call.argument<Boolean>("enabled")
            Applanga.setShowIdModeEnabled(enabled!!);
            result.success(null)
        } else if (call.method == "takeScreenshotWithTag") {
            val tag = call.argument<String>("tag")
            val stringIds = call.argument<List<String>>("stringIds")!!
            val stringPos = call.argument<String>("stringPos")!!
            Applanga.captureScreenshot(tag, stringIds, stringPos) { aBoolean ->
                theActivity!!.runOnUiThread(Runnable { result.success(aBoolean) })
            }
        }  else if (call.method == "update") {
            val groups = call.argument<List<String>>("groups");
            val languages = call.argument<List<String>>("languages");
            Applanga.update(groups, languages
            ) { b ->
                theActivity?.runOnUiThread(Runnable { result.success(b) })
            }
        } else if (call.method == "localizeMap") {
            val map: HashMap<String, HashMap<String, String>> =
                if (call.arguments is HashMap<*, *>) call.arguments as HashMap<String, HashMap<String, String>> else HashMap()
            val applangaMap = Applanga.localizeMap(map, false)
            result.success(applangaMap)
        } else if (call.method == "isDebuggerConnected") {
            result.success(Debug.isDebuggerConnected())
        } else if (call.method == "setLanguage") {
            val lang = call.argument<String>("lang")
            result.success(Applanga.setLanguage(lang))
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
