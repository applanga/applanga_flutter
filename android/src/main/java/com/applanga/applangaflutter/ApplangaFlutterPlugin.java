package com.applanga.applangaflutter;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;


import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.embedding.engine.renderer.FlutterRenderer;

import com.applanga.android.Applanga;
import com.applanga.android.ApplangaCallback;
import com.applanga.android.ApplangaScreenshotInterface;


import java.util.HashMap;
import java.util.List;

/**
 * ApplangaFlutterPlugin
 */
public class ApplangaFlutterPlugin implements MethodCallHandler  {
  
  private static Registrar registrar = null;

  private static Object renderer;

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "applanga_flutter");
    channel.setMethodCallHandler(new ApplangaFlutterPlugin());
    ApplangaFlutterPlugin.registrar = registrar;
    Applanga.init(registrar.activeContext());
    renderer = registrar.view();
  }

  private Bitmap getTheScreenshot()
  {
    try {
      View view = registrar.activity().getWindow().getDecorView().getRootView();
      view.setDrawingCacheEnabled(true);
      Bitmap bitmap = null;
      if( renderer.getClass().getSimpleName().equals("FlutterView") ) {
        bitmap = ( (FlutterView) renderer ).getBitmap();
      } else if( renderer.getClass().getSimpleName().equals("FlutterRenderer") ) {
        bitmap = ( (FlutterRenderer) renderer ).getBitmap();
      }
      view.setDrawingCacheEnabled(false);
      return bitmap;
    } catch (Exception ex) {
      Log.println(Log.INFO, "APPLANGA", "Error taking screenshot: " + ex.getMessage());
    }
    return null;
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    //Log.d("onMethodCall", "name = " + call.method);
    if (call.method.equals("getString")) {

      String key = call.argument("key");

      String defaultValue = call.argument("defaultValue");

      Log.d("applanga", "calling get string with key: " + key + " and default value: " + defaultValue);

      result.success(Applanga.getString(key, defaultValue));

    } else if (call.method.equals("takeScreenshotWithTag")) {

      String tag = call.argument("tag");

      Boolean useOcr = call.argument("useOcr");

      Applanga.setOcrEnabled(useOcr);

      List<String> stringIds = call.argument("stringIds");

      Applanga.captureScreenshot(tag,stringIds);

      result.success(null);

    }else if (call.method.equals("setlanguage")) {

      String lang = call.argument("lang");

      Applanga.setLanguage(lang);

      result.success(null);

    }else if (call.method.equals("update")){
      Applanga.update(new ApplangaCallback() {
        @Override
        public void onLocalizeFinished(final boolean b) {
          Log.d("applanga", String.format("onLocalizeFinished(%b)", b));
          if(registrar != null){
           registrar.activity().runOnUiThread(new Runnable() {
             @Override
             public void run() {
               result.success(b);
             }
           });
          }
        }
      });

      Applanga.setScreenshotInterface(new ApplangaScreenshotInterface(){
          @Override
        public Bitmap getScreenshot(){
            return getTheScreenshot();
          }
      });

    } else if(call.method.equals("localizeMap")) {
      HashMap<String, HashMap<String, String>> map =
              (call.arguments instanceof HashMap<?,?>) ? (HashMap)call.arguments : new HashMap<>();
      HashMap<String, HashMap<String,String>> applangaMap = Applanga.localizeMap(map);
      result.success(applangaMap);
    } else if(call.method.equals("isDebuggerConnected")) {
      result.success(android.os.Debug.isDebuggerConnected());
    } else if(call.method.equals("setLanguage")) {
      result.success(Applanga.setLanguage(call.arguments.toString()));
    } else if(call.method.equals("showDraftModeDialog")) {
      Activity activity = null;
      if(registrar != null){
        activity = registrar.activity();
      }
      if( activity != null ) {
        Applanga.showDraftModeDialog(activity);
        result.success(null);
      } else {
        result.error("DraftModeDialog", "Activity not found?", null);
      }
    }else if(call.method.equals("showScreenShotMenu")){
      Applanga.setScreenShotMenuVisible(true);
      result.success(null);
    }else if(call.method.equals("hideScreenShotMenu")){
      Applanga.setScreenShotMenuVisible(false);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

}
