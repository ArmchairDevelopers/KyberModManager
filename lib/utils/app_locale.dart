import 'dart:io';
import 'dart:ui';

import 'package:kyber_mod_manager/main.dart';

class AppLocale {
  Locale getLocale() {
    return Locale.fromSubtags(languageCode: box.get('locale', defaultValue: Platform.localeName.split('_').first));
  }
}
