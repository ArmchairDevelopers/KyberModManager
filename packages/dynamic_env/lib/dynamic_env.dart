import 'dynamic_env_platform_interface.dart';

class DynamicEnv {
  Future<void> setEnv(int pid, String name, String value) async {
    return DynamicEnvPlatform.instance.setEnv(pid, name, value);
  }
}
