import 'dart:io';
import 'dart:ui';

import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';

class TranslatePreferences extends ITranslatePreferences {
  @override
  Future<Locale?> getPreferredLocale() async {
    return Locale.fromSubtags(languageCode: box.get('locale', defaultValue: Platform.localeName.split('_').first));
  }

  @override
  Future savePreferredLocale(Locale locale) async {
    await box.put('locale', locale.toString());
  }
}
