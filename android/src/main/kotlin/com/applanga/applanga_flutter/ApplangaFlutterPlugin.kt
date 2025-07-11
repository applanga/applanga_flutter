package com.applanga.applanga_flutter

import android.app.Activity
import android.graphics.Bitmap
import android.os.Build
import android.os.Debug
import android.view.MotionEvent
import android.widget.Toast
import com.applanga.android.`$InternalALPlugin`
import com.applanga.android.Applanga
import com.applanga.android.ApplangaScreenshotInterface
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** ApplangaFlutterPlugin */
class ApplangaFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel

    private var theActivity: Activity? = null

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
        var msg =
            "No screenshot support for api levels below 24. See applanga_flutter documentation."
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            msg = "Something went wrong with the screenshot. Please contact Applanga support."
        }
        if (theActivity != null) {
            Toast.makeText(
                theActivity,
                msg,
                Toast.LENGTH_LONG
            )
                .show()
        }

        return null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "init") {
            `$InternalALPlugin`.setScreenshotInterface(object : ApplangaScreenshotInterface {
                override fun onCaptureScreenshotFromOverlay(screenTag: String) {
                    channel.invokeMethod("captureScreenshotFromOverlay", screenTag)
                }

                override fun getScreenshot(): Bitmap {
                    return getTheScreenshot()!!
                }
            })
        } else if (call.method == "setShowIdModeEnabled") {
            val enabled = call.argument<Boolean>("enabled")
            Applanga.setShowIdModeEnabled(enabled!!)
            result.success(null)
        } else if (call.method == "takeScreenshotWithTag") {
            val tag = call.argument<String>("tag")
            val stringIds = call.argument<List<String>>("stringIds")!!
            val stringPos = call.argument<String>("stringPos")!!
            Applanga.captureScreenshot(tag, stringIds, stringPos) { aBoolean ->
                var msg = "Screenshot captured."
                if (!aBoolean) {
                    msg = "Something went wrong with the screenshot."
                }
                theActivity!!.runOnUiThread {
                    Toast.makeText(theActivity!!, msg, Toast.LENGTH_SHORT)
                        .show()
                    result.success(aBoolean)
                }
            }
        } else if (call.method == "update") {
            val groups = call.argument<List<String>>("groups")
            val languages = call.argument<List<String>>("languages")
            Applanga.update(
                groups, languages
            ) { b ->
                theActivity?.runOnUiThread { result.success(b) }
            }
        } else if (call.method == "localizeMap") {
            val tmpMap = call.arguments as HashMap<*, *>
            var map: HashMap<String, HashMap<String, String>> = HashMap()
            if (
                tmpMap.all {
                    it.key is String && it.value is HashMap<*, *> && (it.value as HashMap<*, *>).all { inner ->
                        inner.key is String && inner.value is String?
                    }
                }
            ) {
                @Suppress("UNCHECKED_CAST")
                map = tmpMap as HashMap<String, HashMap<String, String>>
            }
            val applangaMap = Applanga.localizeMap(map, false)
            result.success(applangaMap)
        } else if (call.method == "localizedStringsForLanguages") {
            val tmpLanguages = call.arguments as List<*>
            var languages: List<String> = ArrayList()
            if (
                tmpLanguages.all {
                    it is String
                }
            ) {
                @Suppress("UNCHECKED_CAST")
                languages = tmpLanguages as List<String>
            }
            val applangaMap = Applanga.localizedStringsForLanguages(languages)
            result.success(applangaMap)
        } else if (call.method == "isDebuggerConnected") {
            result.success(Debug.isDebuggerConnected())
        } else if (call.method == "setLanguage") {
            val lang = call.argument<String>("lang")
            result.success(Applanga.setLanguage(lang, false))
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
        } else if (call.method == "getSettingsFileBranchId") {
            val branchId = Applanga.getSettingsFileBranchId()
            result.success(branchId)
        } else {
            result.notImplemented()
        }
    }


}
