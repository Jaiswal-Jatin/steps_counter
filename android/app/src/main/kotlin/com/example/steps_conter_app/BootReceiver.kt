package com.example.steps_conter_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Boot completed received!")
            // You might want to restart your background services or schedule tasks here
            // For example, if you have a StepCounterService, you might start it here.
            // val serviceIntent = Intent(context, StepCounterService::class.java)
            // context?.startService(serviceIntent)
        }
    }
}
