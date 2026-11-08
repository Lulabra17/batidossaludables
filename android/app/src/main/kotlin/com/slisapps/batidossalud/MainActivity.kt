package com.slisapps.batidossalud

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Clear corrupt notification cache before Flutter/Dart starts.
        // flutter_local_notifications stored data without Gson type discriminators (v17).
        // v18 added RuntimeTypeAdapterFactory which requires them → all plugin calls fail.
        // Fix: write "[]" (valid empty JSON) synchronously before Dart code runs.
        clearCorruptNotifCacheIfNeeded()
        super.onCreate(savedInstanceState)
    }

    private fun clearCorruptNotifCacheIfNeeded() {
        val flag = applicationContext.getSharedPreferences(
            "batidos_notif_fix", Context.MODE_PRIVATE
        )
        if (!flag.getBoolean("v1", false)) {
            applicationContext
                .getSharedPreferences("scheduled_notifications", Context.MODE_PRIVATE)
                .edit()
                .putString("scheduled_notifications", "[]")
                .commit()
            flag.edit().putBoolean("v1", true).commit()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.slisapps.batidossalud/notifications"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLocalTimezone" -> {
                    result.success(java.util.TimeZone.getDefault().id)
                }
                else -> result.notImplemented()
            }
        }
    }
}
