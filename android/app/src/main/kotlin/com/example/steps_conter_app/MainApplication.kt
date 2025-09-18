package com.example.steps_conter_app

import androidx.multidex.MultiDex
import android.content.Context
import io.flutter.app.FlutterApplication

class MainApplication : FlutterApplication() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
