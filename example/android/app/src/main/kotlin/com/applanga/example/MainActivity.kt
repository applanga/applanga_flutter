package com.applanga.example

import android.view.MotionEvent
import com.applanga.android.Applanga
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        Applanga.dispatchTouchEvent(ev, this)
        return super.dispatchTouchEvent(ev)
    }

}
