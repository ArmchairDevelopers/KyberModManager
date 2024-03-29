import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_collection.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';
import 'package:logging/logging.dart';

class StorageHelper {
  static final Map<String, dynamic> _defaultValues = {
    'cosmetics': [],
    'discordRPC': true,
    'saveProfiles': true,
    'enableCosmetics': false,
    'beta': false,
    'enableDynamicEnv': true,
  };

  static Future<void> initializeHive() async {
    await Hive.initFlutter(applicationDocumentsDirectory);
    Hive.registerAdapter(ModProfileAdapter(), override: true);
    Hive.registerAdapter(ModAdapter(), override: true);
    Hive.registerAdapter(FrostyCollectionAdapter(), override: true);
    box = await Hive.openBox('data').catchError((e) {
      if (kDebugMode) {
        return null;
      }
      Logger.root.severe('Error opening box: $e');
      exit(1);
    });
    _defaultValues.keys.where((key) => !box.containsKey(key)).forEach((key) => box.put(key, _defaultValues[key]));
    dynamicEnvEnabled = box.get('enableDynamicEnv') as bool;
  }
}
