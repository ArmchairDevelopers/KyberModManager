//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <auto_update/auto_update_plugin.h>
#include <dart_discord_rpc/dart_discord_rpc_plugin.h>
#include <sentry_flutter/sentry_flutter_plugin.h>
#include <system_theme/system_theme_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <windows_taskbar/windows_taskbar_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AutoUpdatePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AutoUpdatePlugin"));
  DartDiscordRpcPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DartDiscordRpcPlugin"));
  SentryFlutterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SentryFlutterPlugin"));
  SystemThemePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SystemThemePlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WindowsTaskbarPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsTaskbarPlugin"));
}
