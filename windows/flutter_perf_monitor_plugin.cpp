#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <psapi.h>
#include <pdh.h>
#include <memory>
#include <sstream>

namespace {

class FlutterPerfMonitorPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterPerfMonitorPlugin();

  virtual ~FlutterPerfMonitorPlugin();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  int64_t GetWindowsMemoryUsage();
  double GetWindowsCPUUsage();
  int64_t GetWindowsTotalMemory();
};

// static
void FlutterPerfMonitorPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "flutter_perf_monitor",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterPerfMonitorPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterPerfMonitorPlugin::FlutterPerfMonitorPlugin() {}

FlutterPerfMonitorPlugin::~FlutterPerfMonitorPlugin() {}

void FlutterPerfMonitorPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getWindowsMemoryUsage") == 0) {
    int64_t memoryUsage = GetWindowsMemoryUsage();
    result->Success(flutter::EncodableValue(memoryUsage));
  } else if (method_call.method_name().compare("getWindowsCPUUsage") == 0) {
    double cpuUsage = GetWindowsCPUUsage();
    result->Success(flutter::EncodableValue(cpuUsage));
  } else if (method_call.method_name().compare("getWindowsTotalMemory") == 0) {
    int64_t totalMemory = GetWindowsTotalMemory();
    result->Success(flutter::EncodableValue(totalMemory));
  } else {
    result->NotImplemented();
  }
}

int64_t FlutterPerfMonitorPlugin::GetWindowsMemoryUsage() {
  PROCESS_MEMORY_COUNTERS pmc;
  if (GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc))) {
    return static_cast<int64_t>(pmc.WorkingSetSize);
  }
  return 0;
}

double FlutterPerfMonitorPlugin::GetWindowsCPUUsage() {
  static PDH_HQUERY cpuQuery;
  static PDH_HCOUNTER cpuTotal;
  static bool initialized = false;
  
  if (!initialized) {
    PdhOpenQuery(NULL, NULL, &cpuQuery);
    PdhAddEnglishCounter(cpuQuery, L"\\Processor(_Total)\\% Processor Time", NULL, &cpuTotal);
    PdhCollectQueryData(cpuQuery);
    initialized = true;
    return 0.0; // First call returns 0
  }
  
  PDH_FMT_COUNTERVALUE counterVal;
  PdhCollectQueryData(cpuQuery);
  PdhGetFormattedCounterValue(cpuTotal, PDH_FMT_DOUBLE, NULL, &counterVal);
  
  return counterVal.doubleValue;
}

int64_t FlutterPerfMonitorPlugin::GetWindowsTotalMemory() {
  MEMORYSTATUSEX memInfo;
  memInfo.dwLength = sizeof(MEMORYSTATUSEX);
  if (GlobalMemoryStatusEx(&memInfo)) {
    return static_cast<int64_t>(memInfo.ullTotalPhys);
  }
  return 0;
}

}  // namespace

void FlutterPerfMonitorPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  FlutterPerfMonitorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
