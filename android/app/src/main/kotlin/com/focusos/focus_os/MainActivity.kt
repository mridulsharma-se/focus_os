package com.focusos.focus_os

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.focusos.channel/notifications"
    private lateinit var channel: MethodChannel
    
    private val notificationReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val packageName = intent.getStringExtra("package_name") ?: ""
            val title = intent.getStringExtra("title") ?: ""
            val text = intent.getStringExtra("text") ?: ""
            val timestamp = intent.getLongExtra("timestamp", 0)
            
            val notificationData = mapOf(
                "package_name" to packageName,
                "title" to title,
                "text" to text,
                "timestamp" to timestamp
            )
            
            // Invoke Methodist on the main thread, though onReceive is typically main thread.
            channel.invokeMethod("onNotificationReceived", notificationData)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        channel.setMethodCallHandler { call, result ->
            if (call.method == "checkNotificationPermission") {
                val enabled = android.provider.Settings.Secure.getString(
                    context.contentResolver, 
                    "enabled_notification_listeners"
                )?.contains(context.packageName) == true
                result.success(enabled)
            } else if (call.method == "requestNotificationPermission") {
                startActivity(Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"))
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val filter = IntentFilter("com.focusos.NOTIFICATION_POSTED")
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(notificationReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(notificationReceiver, filter)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(notificationReceiver)
    }
}
