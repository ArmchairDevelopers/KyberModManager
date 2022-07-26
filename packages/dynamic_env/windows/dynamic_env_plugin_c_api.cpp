#include "include/dynamic_env/dynamic_env_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "dynamic_env_plugin.h"

void DynamicEnvPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  dynamic_env::DynamicEnvPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
