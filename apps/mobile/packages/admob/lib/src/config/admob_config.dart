import 'dart:io';

/// AdMob 광고 단위 ID 설정
class AdMobConfig {
  // 테스트 모드 (개발 시 true)
  static const bool isTestMode = true;

  // Android Ad Unit IDs
  static const String androidBannerAdUnitId = isTestMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';

  static const String androidInterstitialAdUnitId = isTestMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';

  static const String androidRewardedAdUnitId = isTestMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';

  // iOS Ad Unit IDs
  static const String iosBannerAdUnitId = isTestMode
      ? 'ca-app-pub-3940256099942544/2934735716'
      : 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';

  static const String iosInterstitialAdUnitId = isTestMode
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';

  static const String iosRewardedAdUnitId = isTestMode
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';

  // Platform-agnostic getters
  static String get bannerAdUnitId {
    if (Platform.isAndroid) return androidBannerAdUnitId;
    if (Platform.isIOS) return iosBannerAdUnitId;
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) return androidInterstitialAdUnitId;
    if (Platform.isIOS) return iosInterstitialAdUnitId;
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) return androidRewardedAdUnitId;
    if (Platform.isIOS) return iosRewardedAdUnitId;
    throw UnsupportedError('Unsupported platform');
  }
}
