import 'dart:io';
import 'dart:ui';

import 'package:kyber_mod_manager/main.dart';

class AppLocale {
  Locale getLocale() {
    try {
      return Locale.fromSubtags(languageCode: box.get('locale', defaultValue: Platform.localeName.split('_').first));
    } catch (e) {
      return const Locale.fromSubtags(languageCode: 'en-US');
    }
  }
}
