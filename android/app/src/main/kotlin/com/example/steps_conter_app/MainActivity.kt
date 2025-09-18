package com.example.steps_conter_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Intent
import androidx.core.content.ContextCompat

class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL = "com.example.steps_counter_app/background_service"
    private val EVENT_CHANNEL = "com.example.steps_counter_app/step_updates"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "startService") {
                val serviceIntent = Intent(this, StepCounterService::class.java)
                ContextCompat.startForegroundService(this, serviceIntent)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    StepCounterService.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    StepCounterService.eventSink = null
                }
            }
        )
    }
}
