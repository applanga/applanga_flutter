package com.applanga.applanga_flutter_test_app

import android.os.Bundle
import android.view.MotionEvent

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
  }

  override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
    com.applanga.applangaflutter.ApplangaFlutterPlugin.dispatchTouchEvent(ev, this)
    return super.dispatchTouchEvent(ev)
  }
}
