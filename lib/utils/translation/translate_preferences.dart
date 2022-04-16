import 'dart:ui';

import 'package:flutter_translate/flutter_translate.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/app_locale.dart';

class TranslatePreferences extends ITranslatePreferences {
  @override
  Future<Locale?> getPreferredLocale() async {
    return AppLocale().getLocale();
  }

  @override
  Future savePreferredLocale(Locale locale) async {
    await Jiffy.locale(locale.languageCode);
    await box.put('locale', locale.toString());
  }
}
