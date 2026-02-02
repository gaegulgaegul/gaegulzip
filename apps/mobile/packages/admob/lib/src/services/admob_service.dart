import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../config/admob_config.dart';

/// AdMob 서비스
class AdMobService extends GetxService {
  final isInitialized = false.obs;
  final initializationError = Rx<String?>(null);

  /// AdMob SDK 초기화
  Future<void> initialize() async {
    try {
      final initializationStatus = await MobileAds.instance.initialize();
      Logger.info('AdMob initialized: ${initializationStatus.adapterStatuses}');

      isInitialized.value = true;
      initializationError.value = null;
    } catch (e) {
      Logger.error('AdMob initialization failed', error: e);
      isInitialized.value = false;
      initializationError.value = e.toString();
    }
  }

  /// 배너 광고 생성
  BannerAd? createBannerAd({
    required AdSize adSize,
    required BannerAdListener listener,
  }) {
    if (!isInitialized.value) {
      Logger.warn('AdMob not initialized. Cannot create banner ad.');
      return null;
    }

    return BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      size: adSize,
      listener: listener,
      request: const AdRequest(),
    );
  }

  /// 전면 광고 로드
  Future<InterstitialAd?> loadInterstitialAd({
    required InterstitialAdLoadCallback callback,
  }) async {
    if (!isInitialized.value) {
      Logger.warn('AdMob not initialized. Cannot load interstitial ad.');
      return null;
    }

    await InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: callback,
    );

    return null;
  }

  /// 리워드 광고 로드
  Future<RewardedAd?> loadRewardedAd({
    required RewardedAdLoadCallback callback,
  }) async {
    if (!isInitialized.value) {
      Logger.warn('AdMob not initialized. Cannot load rewarded ad.');
      return null;
    }

    await RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: callback,
    );

    return null;
  }
}
