import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dynamic_env_platform_interface.dart';

class MethodChannelDynamicEnv extends DynamicEnvPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('dynamic_env');

  @override
  Future<void> setEnv(String proccessName, String name, String value) async {
    await methodChannel.invokeMethod<String>(
      'setEnv',
      <String, dynamic>{
        'proc': proccessName,
        'name': name,
        'value': value,
      },
    );
  }
}
