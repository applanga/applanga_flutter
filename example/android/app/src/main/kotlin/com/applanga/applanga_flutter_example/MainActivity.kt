package com.applanga.applanga_flutter_example

import android.view.MotionEvent
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        com.applanga.applanga_flutter.ApplangaFlutterPlugin.dispatchTouchEvent(ev, this)
        return super.dispatchTouchEvent(ev)
    }
}
