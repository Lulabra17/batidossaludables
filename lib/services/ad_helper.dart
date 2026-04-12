import 'package:flutter/foundation.dart';

class AdHelper {

  /// 🔹 BANNER
  static String get bannerAdUnitId {
    if (kReleaseMode) {
      return 'ca-app-pub-6698527085132528/5073839022'; // REAL
    } else {
      return 'ca-app-pub-3940256099942544/6300978111'; // TEST
    }
  }

  /// 🔹 INTERSTITIAL 1
  static String get interstitialAdUnitIdwelcome {
    if (kReleaseMode) {
      return 'ca-app-pub-6698527085132528/7842080932'; // REAL
    } else {
      return 'ca-app-pub-3940256099942544/1033173712'; // TEST
    }
  }

  /// 🔹 INTERSTITIAL 2
  static String get interstitialAdUnitIdshare {
    if (kReleaseMode) {
      return 'ca-app-pub-6698527085132528/6622508814'; // REAL
    } else {
      return 'ca-app-pub-3940256099942544/1033173712'; // TEST
    }
  }
}