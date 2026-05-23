package com.ben.claude_flutter_v2.flutter_claude_app_v2

import android.content.pm.ApplicationInfo
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // M18/T18.4 防截屏（FLAG_SECURE）：开启后系统禁止截屏/录屏，最近任务显示空白。
        MethodChannel(messenger, "flutter_claude_app/screen_security")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableSecure" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    "disableSecure" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // M18/T18.5 设备完整性：模拟器 / 可调试 / su 路径粗检。
        // 生产请改用 Play Integrity API 等专门方案（见 docs/SECURITY_CHECKLIST.md）。
        MethodChannel(messenger, "flutter_claude_app/device_integrity")
            .setMethodCallHandler { call, result ->
                if (call.method == "check") {
                    val debuggable =
                        (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
                    result.success(
                        mapOf(
                            "isEmulator" to isProbablyEmulator(),
                            "isDebuggable" to debuggable,
                            "isRootedOrJailbroken" to isProbablyRooted(),
                        ),
                    )
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun isProbablyEmulator(): Boolean =
        Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.lowercase().contains("emulator") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.contains("Android SDK built for") ||
            Build.HARDWARE.contains("goldfish") ||
            Build.HARDWARE.contains("ranchu") ||
            Build.PRODUCT.contains("sdk")

    private fun isProbablyRooted(): Boolean {
        val suPaths = listOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
        )
        return suPaths.any { File(it).exists() }
    }
}
