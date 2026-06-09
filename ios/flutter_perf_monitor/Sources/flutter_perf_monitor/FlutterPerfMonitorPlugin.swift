import Flutter
import UIKit
import Darwin

public class FlutterPerfMonitorPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_perf_monitor", binaryMessenger: registrar.messenger())
        let instance = FlutterPerfMonitorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getMemoryInfo":
            getMemoryInfo(result: result)
        case "getCpuUsage":
            getCpuUsage(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getMemoryInfo(result: @escaping FlutterResult) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        guard kerr == KERN_SUCCESS else {
            result(FlutterError(code: "MEMORY_ERROR",
                              message: "Failed to get memory info",
                              details: nil))
            return
        }

        let usedMemory = Int64(info.resident_size)
        
        // Get system memory info
        let totalMemory = getTotalMemory()
        let availableMemory = totalMemory - usedMemory
        let percentUsed = Double(usedMemory) / Double(totalMemory) * 100.0

        let memoryInfo: [String: Any] = [
            "totalMemory": totalMemory,
            "availableMemory": availableMemory,
            "usedMemory": usedMemory,
            "percentUsed": percentUsed
        ]

        result(memoryInfo)
    }

    private func getTotalMemory() -> Int64 {
        return Int64(ProcessInfo.processInfo.physicalMemory)
    }

    private func getCpuUsage(result: @escaping FlutterResult) {
        var threads: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0
        
        defer {
            if let threads = threads {
                vm_deallocate(mach_task_self_,
                            vm_address_t(bitPattern: threads),
                            vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.stride))
            }
        }
        
        let kerr: kern_return_t = task_threads(mach_task_self_, &threads, &threadCount)
        
        guard kerr == KERN_SUCCESS else {
            result(FlutterError(code: "CPU_ERROR",
                              message: "Failed to get CPU info",
                              details: nil))
            return
        }
        
        var totalCpu: Double = 0.0
        var activeCores: Int = 0
        
        if let threads = threads {
            for i in 0..<Int(threadCount) {
                var threadInfo = thread_basic_info()
                var count = mach_msg_type_number_t(THREAD_INFO_MAX)
                let kr = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threads[i],
                                   thread_flavor_t(THREAD_BASIC_INFO),
                                   $0,
                                   &count)
                    }
                }
                
                if kr == KERN_SUCCESS && (threadInfo.flags & TH_FLAGS_IDLE) == 0 {
                    let cpu = Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                    totalCpu += cpu
                    activeCores += 1
                }
            }
        }
        
        // Since iOS doesn't expose per-core CPU usage easily,
        // we return the total usage and simulate per-core
        let avgPerCore = activeCores > 0 ? totalCpu / Double(activeCores) : 0.0
        let cores = activeCores > 0 ? activeCores : 1
        
        var perCoreUsage: [Double] = []
        for _ in 0..<cores {
            perCoreUsage.append(avgPerCore)
        }
        
        let cpuInfo: [String: Any] = [
            "totalUsage": totalCpu,
            "perCoreUsage": perCoreUsage
        ]
        
        result(cpuInfo)
    }
}

