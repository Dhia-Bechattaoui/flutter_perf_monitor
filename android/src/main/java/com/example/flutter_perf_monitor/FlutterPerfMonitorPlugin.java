package com.example.flutter_perf_monitor;

import android.app.ActivityManager;
import android.content.Context;
import android.os.Debug;
import android.os.Process;
import android.os.StatFs;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterPerfMonitorPlugin */
public class FlutterPerfMonitorPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private static final String CHANNEL = "flutter_perf_monitor";
    private MethodChannel channel;
    private Context context;
    private ActivityManager activityManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            switch (call.method) {
                case "getAndroidMemoryUsage":
                    result.success(getAndroidMemoryUsage());
                    break;
                case "getAndroidCPUUsage":
                    result.success(getAndroidCPUUsage());
                    break;
                case "getAndroidTotalMemory":
                    result.success(getAndroidTotalMemory());
                    break;
                default:
                    result.notImplemented();
                    break;
            }
        } catch (Exception e) {
            Log.e("FlutterPerfMonitor", "Error in method call: " + call.method, e);
            result.error("ERROR", e.getMessage(), null);
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityManager = (ActivityManager) binding.getActivity().getSystemService(Context.ACTIVITY_SERVICE);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activityManager = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activityManager = (ActivityManager) binding.getActivity().getSystemService(Context.ACTIVITY_SERVICE);
    }

    @Override
    public void onDetachedFromActivity() {
        activityManager = null;
    }

    private long getAndroidMemoryUsage() {
        try {
            if (activityManager != null) {
                ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
                activityManager.getMemoryInfo(memoryInfo);
                
                // Get app-specific memory usage
                Debug.MemoryInfo[] memoryInfoArray = activityManager.getProcessMemoryInfo(
                    new int[]{Process.myPid()}
                );
                
                if (memoryInfoArray.length > 0) {
                    Debug.MemoryInfo processMemoryInfo = memoryInfoArray[0];
                    return processMemoryInfo.getTotalPss() * 1024; // Convert KB to bytes
                }
            }
            
            // Fallback: use Debug.getNativeHeapSize()
            return Debug.getNativeHeapSize();
        } catch (Exception e) {
            Log.e("FlutterPerfMonitor", "Error getting memory usage", e);
            return 0;
        }
    }

    private double getAndroidCPUUsage() {
        try {
            // Read CPU usage from /proc/stat
            BufferedReader reader = new BufferedReader(new FileReader("/proc/stat"));
            String line = reader.readLine();
            reader.close();
            
            if (line != null && line.startsWith("cpu ")) {
                String[] parts = line.split("\\s+");
                if (parts.length >= 8) {
                    long user = Long.parseLong(parts[1]);
                    long nice = Long.parseLong(parts[2]);
                    long system = Long.parseLong(parts[3]);
                    long idle = Long.parseLong(parts[4]);
                    long iowait = Long.parseLong(parts[5]);
                    long irq = Long.parseLong(parts[6]);
                    long softirq = Long.parseLong(parts[7]);
                    
                    long totalCpuTime = user + nice + system + idle + iowait + irq + softirq;
                    long totalCpuUsage = totalCpuTime - idle;
                    
                    if (totalCpuTime > 0) {
                        return (double) totalCpuUsage / totalCpuTime * 100.0;
                    }
                }
            }
            
            return 0.0;
        } catch (Exception e) {
            Log.e("FlutterPerfMonitor", "Error getting CPU usage", e);
            return 0.0;
        }
    }

    private long getAndroidTotalMemory() {
        try {
            if (activityManager != null) {
                ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
                activityManager.getMemoryInfo(memoryInfo);
                return memoryInfo.totalMem;
            }
            
            // Fallback: try to read from /proc/meminfo
            BufferedReader reader = new BufferedReader(new FileReader("/proc/meminfo"));
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("MemTotal:")) {
                    String[] parts = line.split("\\s+");
                    if (parts.length >= 2) {
                        long memTotalKB = Long.parseLong(parts[1]);
                        reader.close();
                        return memTotalKB * 1024; // Convert KB to bytes
                    }
                }
            }
            reader.close();
            
            return 0;
        } catch (Exception e) {
            Log.e("FlutterPerfMonitor", "Error getting total memory", e);
            return 0;
        }
    }
}
