import Flutter
import UIKit
import Foundation
import os

public class FlutterPerfMonitorPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_perf_monitor", binaryMessenger: registrar.messenger())
        let instance = FlutterPerfMonitorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getIOSMemoryUsage":
            result(getIOSMemoryUsage())
        case "getIOSCPUUsage":
            result(getIOSCPUUsage())
        case "getIOSTotalMemory":
            result(getIOSTotalMemory())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getIOSMemoryUsage() -> Int64 {
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

        if kerr == KERN_SUCCESS {
            return Int64(info.resident_size)
        } else {
            os_log("Error getting memory usage: %d", log: OSLog.default, type: .error, kerr)
            return 0
        }
    }

    private func getIOSCPUUsage() -> Double {
        var info = processor_info_array_t.allocate(capacity: 1)
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCpus: natural_t = 0
        let result = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &numCpus,
                                       &info,
                                       &numCpuInfo)

        if result == KERN_SUCCESS {
            let cpuInfo = info.withMemoryRebound(to: processor_cpu_load_info_t.self, capacity: 1) { $0 }
            let cpuLoad = cpuInfo.pointee
            
            let user = Double(cpuLoad.cpu_ticks.0)
            let system = Double(cpuLoad.cpu_ticks.1)
            let nice = Double(cpuLoad.cpu_ticks.2)
            let idle = Double(cpuLoad.cpu_ticks.3)
            
            let total = user + system + nice + idle
            if total > 0 {
                return ((user + system + nice) / total) * 100.0
            }
        } else {
            os_log("Error getting CPU usage: %d", log: OSLog.default, type: .error, result)
        }
        
        info.deallocate()
        return 0.0
    }

    private func getIOSTotalMemory() -> Int64 {
        return Int64(ProcessInfo.processInfo.physicalMemory)
    }
}
