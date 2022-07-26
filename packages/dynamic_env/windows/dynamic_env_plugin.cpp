#include "dynamic_env_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <stdio.h>
#include <tlhelp32.h>

namespace dynamic_env {

// static
void DynamicEnvPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "dynamic_env",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<DynamicEnvPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

DynamicEnvPlugin::DynamicEnvPlugin() {}

DynamicEnvPlugin::~DynamicEnvPlugin() {}

void DynamicEnvPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("setEnv") == 0) {
    const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    auto proc = arguments->find(flutter::EncodableValue("proc"));
    auto name = arguments->find(flutter::EncodableValue("name"));
    auto value = arguments->find(flutter::EncodableValue("value"));
    SetEnv(std::get<std::string>(proc->second).c_str(), std::get<std::string>(name->second).c_str(), std::get<std::string>(value->second).c_str(), std::move(result));
  } else {
    result->NotImplemented();
  }
}

// No idea how this works. Thanks to BattleDash for doing this
void DynamicEnvPlugin::SetEnv(const char *proc, const char *name, const char *value, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  DWORD pid = 0;
  HANDLE hProcess = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  PROCESSENTRY32 pe;
  pe.dwSize = sizeof(PROCESSENTRY32);
  if (Process32First(hProcess, &pe)) {
    do {
      if (strcmp((char *)pe.szExeFile, proc) == 0) {
        pid = pe.th32ProcessID;
        break;
      }
    } while (Process32Next(hProcess, &pe));
  }
  CloseHandle(hProcess);
  HANDLE hProcessOrigin = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
  char payload[256];
  snprintf(payload, sizeof(payload), "%s=%s", name, value);
  LPVOID lpMemory = VirtualAllocEx(hProcessOrigin, NULL, strlen(payload) + 1,
                                   MEM_COMMIT, PAGE_READWRITE);
  WriteProcessMemory(hProcessOrigin, lpMemory, payload, strlen(payload) + 1,
                     NULL);
  HANDLE hThread =
      CreateRemoteThread(hProcessOrigin, NULL, 0,
                         (LPTHREAD_START_ROUTINE)GetProcAddress(
                             LoadLibrary(L"ucrtbase.dll"), "_putenv"),
                         lpMemory, 0, NULL);
  WaitForSingleObject(hThread, INFINITE);
  VirtualFreeEx(hProcessOrigin, lpMemory, 0, MEM_RELEASE);
  CloseHandle(hThread);
  CloseHandle(hProcessOrigin);
  result->Success();
}

}  // namespace dynamic_env
