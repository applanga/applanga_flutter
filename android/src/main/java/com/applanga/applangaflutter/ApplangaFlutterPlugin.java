package com.applanga.applangaflutter;

import android.app.Activity;
import android.util.Log;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import com.applanga.android.Applanga;
import com.applanga.android.ApplangaCallback;

import java.util.HashMap;

/**
 * ApplangaFlutterPlugin
 */
public class ApplangaFlutterPlugin implements MethodCallHandler {
  
  private static Registrar registrar = null;
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "applanga_flutter");
    channel.setMethodCallHandler(new ApplangaFlutterPlugin());
    ApplangaFlutterPlugin.registrar = registrar;
    Applanga.init(registrar.activeContext());
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    //Log.d("onMethodCall", "name = " + call.method);
    if (call.method.equals("getString")) {
      result.success(Applanga.getString(call.arguments.toString(), ""));
    } else if (call.method.equals("update")){
      Applanga.update(new ApplangaCallback() {
        @Override
        public void onLocalizeFinished(boolean b) {
          Log.d("applanga", String.format("onLocalizeFinished(%b)", b));
          result.success(b);
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
    } else {
      result.notImplemented();
    }
  }
}
