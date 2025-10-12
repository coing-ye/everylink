// lib/domain/services/ad_service.dart
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 관리 서비스
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  /// AdMob 초기화 (앱 시작시 한번만 호출)
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// 배너 광고 Unit ID
  ///
  /// ⚠️ 중요: 실제 앱스토어 배포시에는 반드시 본인의 AdMob Unit ID로 변경하세요!
  ///
  /// 1. AdMob 계정 생성: https://admob.google.com
  /// 2. 앱 등록 후 광고 단위(Ad Unit) 생성
  /// 3. 아래 테스트 ID를 실제 ID로 교체
  ///
  /// Android: AndroidManifest.xml의 APPLICATION_ID도 변경 필요
  /// iOS: Info.plist의 GADApplicationIdentifier도 변경 필요
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Android 테스트 배너 ID
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // iOS 테스트 배너 ID
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// 배너 광고 생성
  BannerAd createBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner, // 320x50
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );
  }
}
