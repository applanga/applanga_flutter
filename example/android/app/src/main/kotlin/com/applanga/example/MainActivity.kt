package com.applanga.example

import android.view.MotionEvent
import com.applanga.applanga_flutter.ApplangaFlutterPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        ApplangaFlutterPlugin.dispatchTouchEvent(ev, this);
        return super.dispatchTouchEvent(ev)
    }

}
