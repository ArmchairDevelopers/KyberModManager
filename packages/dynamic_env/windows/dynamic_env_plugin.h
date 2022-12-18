#ifndef FLUTTER_PLUGIN_DYNAMIC_ENV_PLUGIN_H_
#define FLUTTER_PLUGIN_DYNAMIC_ENV_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace dynamic_env {

class DynamicEnvPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DynamicEnvPlugin();

  virtual ~DynamicEnvPlugin();

  DynamicEnvPlugin(const DynamicEnvPlugin&) = delete;
  DynamicEnvPlugin& operator=(const DynamicEnvPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void SetEnv(const char *procesId, const char *name, const char *value, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace dynamic_env

#endif  // FLUTTER_PLUGIN_DYNAMIC_ENV_PLUGIN_H_
