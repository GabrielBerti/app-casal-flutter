package com.example.app_casal_flutter

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "app_casal_flutter/external_apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "openUrl" -> {

                    val url = call.argument<String>("url")!!

                    val intent = Intent(
                        Intent.ACTION_VIEW,
                        Uri.parse(url)
                    )

                    startActivity(intent)

                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
