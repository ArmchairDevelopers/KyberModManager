import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dynamic_env_method_channel.dart';

abstract class DynamicEnvPlatform extends PlatformInterface {
  DynamicEnvPlatform() : super(token: _token);

  static final Object _token = Object();

  static DynamicEnvPlatform _instance = MethodChannelDynamicEnv();

  static DynamicEnvPlatform get instance => _instance;

  static set instance(DynamicEnvPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> setEnv(int pid, String name, String value) {
    throw UnimplementedError('setEnv() has not been implemented.');
  }
}
