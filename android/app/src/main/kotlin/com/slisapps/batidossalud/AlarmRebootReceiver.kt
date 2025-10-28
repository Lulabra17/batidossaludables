package com.slisapps.batidossalud

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class AlarmRebootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            Log.d("AlarmRebootReceiver", "Reinicio detectado, iniciando reprogramación de alarmas")

            // Iniciar un FlutterEngine en modo headless (sin UI)
            val flutterEngine = FlutterEngine(context)
            flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            // Cachear el engine para poder usarlo en el canal, si fuera necesario
            FlutterEngineCache.getInstance().put("alarm_engine", flutterEngine)

            // Usar un MethodChannel para llamar a la función Dart que reprograma las alarmas
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.slisapps.batidossalud/alarm")
            channel.invokeMethod("reprogramAlarms", null)
        }
    }
}