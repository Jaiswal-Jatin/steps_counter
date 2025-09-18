package com.example.steps_conter_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel
import android.content.SharedPreferences
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class StepCounterService : Service(), SensorEventListener {

    private var sensorManager: SensorManager? = null
    private var stepSensor: Sensor? = null
    private var stepsToday = 0
    private var lastSensorValue = 0
    private lateinit var sharedPreferences: SharedPreferences

    companion object {
        var eventSink: EventChannel.EventSink? = null
        private const val NOTIFICATION_CHANNEL_ID = "step_counter_channel"
        private const val NOTIFICATION_ID = 1
        private const val PREFS_NAME = "step_counter_prefs"
        private const val KEY_STEPS_TODAY = "steps_today"
        private const val KEY_LAST_SENSOR_VALUE = "last_sensor_value"
        private const val KEY_CURRENT_DAY = "current_day"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("StepCounterService", "Service Created")
        sharedPreferences = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        loadData()

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)

        if (stepSensor == null) {
            Log.e("StepCounterService", "No Step Counter Sensor found!")
        } else {
            sensorManager?.registerListener(this, stepSensor, SensorManager.SENSOR_DELAY_UI)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("StepCounterService", "Service Started")
        createNotificationChannel()
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_COUNTER) {
            val currentSensorValue = event.values[0].toInt()

            val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
            val savedDate = sharedPreferences.getString(KEY_CURRENT_DAY, "")

            if (today != savedDate) {
                // New day
                stepsToday = 0
                lastSensorValue = currentSensorValue
                sharedPreferences.edit()
                    .putString(KEY_CURRENT_DAY, today)
                    .putInt(KEY_STEPS_TODAY, stepsToday)
                    .putInt(KEY_LAST_SENSOR_VALUE, lastSensorValue)
                    .apply()
            } else {
                // Same day, calculate steps since last event
                val stepsSinceLastEvent = if (currentSensorValue < lastSensorValue) {
                    // Reboot detected, count steps since reboot
                    currentSensorValue
                } else {
                    currentSensorValue - lastSensorValue
                }
                stepsToday += stepsSinceLastEvent
                lastSensorValue = currentSensorValue
                saveData()
            }
            eventSink?.success(stepsToday) // Send today's steps to Flutter
            Log.d("StepCounterService", "Today's Steps: $stepsToday")
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Not used
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager?.unregisterListener(this)
        Log.d("StepCounterService", "Service Destroyed")
        saveData() // Save current steps before destroying
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Step Counter Service Channel",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("Step Counter")
            .setContentText("Counting your steps in the background.")
            .setSmallIcon(R.mipmap.ic_launcher) // Use your app's launcher icon
            .setContentIntent(pendingIntent)
            .build()
    }

    private fun loadData() {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
        val savedDate = sharedPreferences.getString(KEY_CURRENT_DAY, "")
        if (today == savedDate) {
            // It's the same day, load the saved counts
            stepsToday = sharedPreferences.getInt(KEY_STEPS_TODAY, 0)
            lastSensorValue = sharedPreferences.getInt(KEY_LAST_SENSOR_VALUE, 0)
        } else {
            // It's a new day. Let onSensorChanged handle the reset.
            stepsToday = 0
            lastSensorValue = 0
        }
    }

    private fun saveData() {
        sharedPreferences.edit()
            .putInt(KEY_STEPS_TODAY, stepsToday)
            .putInt(KEY_LAST_SENSOR_VALUE, lastSensorValue)
            .apply()
    }
}
