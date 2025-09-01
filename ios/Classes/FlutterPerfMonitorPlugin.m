#import "FlutterPerfMonitorPlugin.h"
#import <Flutter/Flutter.h>

@implementation FlutterPerfMonitorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_perf_monitor"
            binaryMessenger:[registrar messenger]];
  FlutterPerfMonitorPlugin* instance = [[FlutterPerfMonitorPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getIOSMemoryUsage" isEqualToString:call.method]) {
    result([self getIOSMemoryUsage]);
  } else if ([@"getIOSCPUUsage" isEqualToString:call.method]) {
    result([self getIOSCPUUsage]);
  } else if ([@"getIOSTotalMemory" isEqualToString:call.method]) {
    result([self getIOSTotalMemory]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSNumber*)getIOSMemoryUsage {
  struct mach_task_basic_info info;
  mach_msg_type_number_t size = sizeof(info);
  kern_return_t kerr = task_info(mach_task_self(),
                                 MACH_TASK_BASIC_INFO,
                                 (task_info_t)&info,
                                 &size);
  
  if (kerr == KERN_SUCCESS) {
    return @(info.resident_size);
  } else {
    NSLog(@"Error getting memory usage: %d", kerr);
    return @0;
  }
}

- (NSNumber*)getIOSCPUUsage {
  processor_info_array_t cpuInfo;
  mach_msg_type_number_t numCpuInfo;
  natural_t numCpus;
  kern_return_t result = host_processor_info(mach_host_self(),
                                           PROCESSOR_CPU_LOAD_INFO,
                                           &numCpus,
                                           &cpuInfo,
                                           &numCpuInfo);
  
  if (result == KERN_SUCCESS) {
    processor_cpu_load_info_t cpuLoad = (processor_cpu_load_info_t)cpuInfo;
    
    double user = (double)cpuLoad->cpu_ticks[CPU_STATE_USER];
    double system = (double)cpuLoad->cpu_ticks[CPU_STATE_SYSTEM];
    double nice = (double)cpuLoad->cpu_ticks[CPU_STATE_NICE];
    double idle = (double)cpuLoad->cpu_ticks[CPU_STATE_IDLE];
    
    double total = user + system + nice + idle;
    if (total > 0) {
      return @(((user + system + nice) / total) * 100.0);
    }
  } else {
    NSLog(@"Error getting CPU usage: %d", result);
  }
  
  vm_deallocate(mach_task_self(), (vm_address_t)cpuInfo, numCpuInfo * sizeof(int));
  return @0.0;
}

- (NSNumber*)getIOSTotalMemory {
  return @([[NSProcessInfo processInfo] physicalMemory]);
}

@end
