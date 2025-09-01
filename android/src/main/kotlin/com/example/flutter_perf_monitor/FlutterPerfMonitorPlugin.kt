package com.example.flutter_perf_monitor

import android.app.ActivityManager
import android.content.Context
import android.os.Debug
import android.os.Process
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.BufferedReader
import java.io.FileReader
import java.io.IOException

class FlutterPerfMonitorPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activityManager: ActivityManager? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_perf_monitor")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        try {
            when (call.method) {
                "getAndroidMemoryUsage" -> result.success(getAndroidMemoryUsage())
                "getAndroidCPUUsage" -> result.success(getAndroidCPUUsage())
                "getAndroidTotalMemory" -> result.success(getAndroidTotalMemory())
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.e("FlutterPerfMonitor", "Error in method call: ${call.method}", e)
            result.error("ERROR", e.message, null)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityManager = binding.activity.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityManager = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityManager = binding.activity.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    }

    override fun onDetachedFromActivity() {
        activityManager = null
    }

    private fun getAndroidMemoryUsage(): Long {
        return try {
            activityManager?.let { am ->
                val memoryInfo = ActivityManager.MemoryInfo()
                am.getMemoryInfo(memoryInfo)
                
                val memoryInfoArray = am.getProcessMemoryInfo(intArrayOf(Process.myPid()))
                if (memoryInfoArray.isNotEmpty()) {
                    val processMemoryInfo = memoryInfoArray[0]
                    (processMemoryInfo.totalPss * 1024).toLong() // Convert KB to bytes
                } else {
                    Debug.getNativeHeapSize()
                }
            } ?: Debug.getNativeHeapSize()
        } catch (e: Exception) {
            Log.e("FlutterPerfMonitor", "Error getting memory usage", e)
            0L
        }
    }

    private fun getAndroidCPUUsage(): Double {
        return try {
            val reader = BufferedReader(FileReader("/proc/stat"))
            val line = reader.readLine()
            reader.close()
            
            if (line != null && line.startsWith("cpu ")) {
                val parts = line.split("\\s+".toRegex())
                if (parts.size >= 8) {
                    val user = parts[1].toLong()
                    val nice = parts[2].toLong()
                    val system = parts[3].toLong()
                    val idle = parts[4].toLong()
                    val iowait = parts[5].toLong()
                    val irq = parts[6].toLong()
                    val softirq = parts[7].toLong()
                    
                    val totalCpuTime = user + nice + system + idle + iowait + irq + softirq
                    val totalCpuUsage = totalCpuTime - idle
                    
                    if (totalCpuTime > 0) {
                        return (totalCpuUsage.toDouble() / totalCpuTime.toDouble()) * 100.0
                    }
                }
            }
            0.0
        } catch (e: Exception) {
            Log.e("FlutterPerfMonitor", "Error getting CPU usage", e)
            0.0
        }
    }

    private fun getAndroidTotalMemory(): Long {
        return try {
            activityManager?.let { am ->
                val memoryInfo = ActivityManager.MemoryInfo()
                am.getMemoryInfo(memoryInfo)
                memoryInfo.totalMem
            } ?: run {
                // Fallback: try to read from /proc/meminfo
                val reader = BufferedReader(FileReader("/proc/meminfo"))
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    if (line!!.startsWith("MemTotal:")) {
                        val parts = line!!.split("\\s+".toRegex())
                        if (parts.size >= 2) {
                            val memTotalKB = parts[1].toLong()
                            reader.close()
                            return memTotalKB * 1024 // Convert KB to bytes
                        }
                    }
                }
                reader.close()
                0L
            }
        } catch (e: Exception) {
            Log.e("FlutterPerfMonitor", "Error getting total memory", e)
            0L
        }
    }
}
