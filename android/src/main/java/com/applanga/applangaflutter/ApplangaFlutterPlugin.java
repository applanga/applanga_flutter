package com.applanga.applangaflutter;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;

import android.graphics.Color;
import android.graphics.Paint;
import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.view.PixelCopy;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;


import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

import com.applanga.android.ALOverlay;
import com.applanga.android.Applanga;
import com.applanga.android.ApplangaCallback;
import com.applanga.android.ApplangaScreenshotInterface;
import com.applanga.android.ScreenshotCallback;


import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * ApplangaFlutterPlugin
 */
public class ApplangaFlutterPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

  private static Activity theActivity = null;

 private static Object mainFlutterView;


  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "applanga_flutter");
    channel.setMethodCallHandler(new ApplangaFlutterPlugin());
    ApplangaFlutterPlugin.theActivity = registrar.activity();
    Applanga.init(registrar.activeContext());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    final MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), "applanga_flutter");
    channel.setMethodCallHandler(new ApplangaFlutterPlugin());
    Applanga.init(binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {

  }

  

  private Bitmap getTheScreenshot()
  {
    try {
        View rootView = theActivity.getWindow().getDecorView().getRootView();
        rootView.setDrawingCacheEnabled(true);

        ViewGroup theGroup = (ViewGroup)rootView;
        FindTheFlutterView(theGroup);


          Bitmap bitmap = null;

        if(mainFlutterView instanceof io.flutter.view.FlutterView) {

            bitmap = ((io.flutter.view.FlutterView) mainFlutterView).getBitmap();

        }else if(mainFlutterView instanceof io.flutter.embedding.android.FlutterView) {

            io.flutter.embedding.android.FlutterView theView = (io.flutter.embedding.android.FlutterView) mainFlutterView;
            theView.setDrawingCacheEnabled(true);
            theView.buildDrawingCache();
            bitmap = theView.getDrawingCache();
            theView.setDrawingCacheEnabled(false);

        }

        rootView.setDrawingCacheEnabled(false);
        mainFlutterView = null;
        return bitmap;

    } catch (Exception ex) {
      Log.println(Log.INFO, "APPLANGA", "Error taking screenshot: " + ex.getMessage());
    }
    return null;
  }

  private void FindTheFlutterView(ViewGroup viewGroup)
  {
    for(int i = 0; i < viewGroup.getChildCount(); i++) {
      View child = (View) viewGroup.getChildAt(i);
      Log.println(Log.INFO, "APPLANGA", "CLASSNAME: " + child.getClass().getSimpleName());
      if(child.getClass().getSimpleName().equals("FlutterView") )
      {
        mainFlutterView = child;
        break;
      }
      if(child instanceof ViewGroup)
      {
        FindTheFlutterView((ViewGroup) child);
      }
    }
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

      List<String> stringIds = call.argument("stringIds");

      Applanga.captureScreenshot(tag,stringIds,useOcr,new ScreenshotCallback<Boolean>() {
        @Override
        public void execute(Boolean aBoolean) {
          if(theActivity != null){
            theActivity.runOnUiThread(new Runnable() {
              @Override
              public void run() {
                Log.i("RICH", "Callback Called in java");
                result.success(null);
              }
            });
          }

        }
      });

    }else if (call.method.equals("setlanguage")) {

      String lang = call.argument("lang");

      Applanga.setLanguage(lang);

      result.success(null);

    }else if (call.method.equals("update")){
      Applanga.update(new ApplangaCallback() {
        @Override
        public void onLocalizeFinished(final boolean b) {
          Log.d("applanga", String.format("onLocalizeFinished(%b)", b));
          if(theActivity != null){
            theActivity.runOnUiThread(new Runnable() {
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
      if( theActivity != null ) {
        Applanga.showDraftModeDialog(theActivity);
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

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    theActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    theActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {

  }

}
