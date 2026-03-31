package com.focusos.focus_os

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent
import android.util.Log

class FocusNotificationListenerService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        sbn?.let { notification ->
            val packageName = notification.packageName
            val extras = notification.notification.extras
            val title = extras.getString("android.title") ?: ""
            val text = extras.getCharSequence("android.text")?.toString() ?: ""

            // Simple filtering: exclude system packages
            if (packageName == "android" || packageName.startsWith("com.android.")) {
                return
            }

            // Sensitive data filtering
            val lowerText = text.lowercase()
            val sensitiveKeywords = listOf("otp", "password", "bank", "verification code", "auth")
            if (sensitiveKeywords.any { lowerText.contains(it) }) {
                Log.d("FocusOS", "Ignored sensitive notification from $packageName")
                return
            }

            // If it passes filters, we should send it to Flutter via Broadcast or bound service.
            // A simple way is to send a broadcast that MainActivity can listen to and forward via MethodChannel.
            val intent = Intent("com.focusos.NOTIFICATION_POSTED")
            intent.putExtra("package_name", packageName)
            intent.putExtra("title", title)
            intent.putExtra("text", text)
            intent.putExtra("timestamp", notification.postTime)
            sendBroadcast(intent)
            
            Log.d("FocusOS", "Captured notification from $packageName")
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
        // Optionally handle removal
    }
}
