# admob — Google AdMob 광고 SDK

## 개요

- **역할**: Google Mobile Ads SDK 래핑 — 배너, 전면, 리워드 광고 관리
- **사용처**: wowa 앱
- **독립성**: `core`에만 의존. 광고 단위 ID는 `AdMobConfig`에서 플랫폼별 관리

## 연동 가이드

```dart
// 1. main.dart에서 초기화
final adMobService = Get.put(AdMobService());
await adMobService.initialize();

// 2. 배너 광고 위젯 사용
BannerAdWidget(adSize: AdSize.banner)

// 3. 전면 광고 로드
adMobService.loadInterstitialAd(callback: InterstitialAdLoadCallback(...));

// 4. 리워드 광고 로드
adMobService.loadRewardedAd(callback: RewardedAdLoadCallback(...));
```

## Public API

| 클래스/함수 | 역할 | 사용 예 |
|------------|------|---------|
| `AdMobService` | SDK 초기화, 광고 생성/로드 (GetxService) | `Get.put(AdMobService())` |
| `AdMobConfig` | 광고 단위 ID 상수 (플랫폼별, 테스트/프로덕션) | `AdMobConfig.bannerAdUnitId` |
| `BannerAdWidget` | 배너 광고 위젯 (자동 로드/표시) | `BannerAdWidget()` |

## Configuration

`AdMobConfig` 상수 클래스:

| 설정 | 설명 |
|------|------|
| `isTestMode` | 테스트 모드 플래그 (true: 테스트 광고 ID, false: 프로덕션 ID) |
| `androidBannerAdUnitId` | Android 배너 광고 단위 ID |
| `iosBannerAdUnitId` | iOS 배너 광고 단위 ID |
| `*InterstitialAdUnitId` | 전면 광고 단위 ID (Android/iOS) |
| `*RewardedAdUnitId` | 리워드 광고 단위 ID (Android/iOS) |

프로덕션 배포 시 `isTestMode`를 `false`로 변경하고 실제 광고 단위 ID를 설정해야 합니다.

## Architecture

```
lib/
├── admob.dart                # 배럴 파일
└── src/
    ├── config/
    │   └── admob_config.dart     # 광고 단위 ID 상수 (테스트/프로덕션, Android/iOS)
    ├── services/
    │   └── admob_service.dart    # SDK 초기화, 광고 생성 (GetxService)
    └── widgets/
        └── banner_ad_widget.dart # 배너 광고 위젯 (StatefulWidget)
```

- `AdMobService`는 `GetxService` — 앱 생명주기 동안 싱글턴
- `BannerAdWidget`은 `StatefulWidget` — 자체 광고 로드/해제 관리
- 초기화 실패 시 에러 로그만 남기고 앱 계속 실행 (`isInitialized` 체크)

## 확장/수정 시

1. 새 광고 형식: `src/widgets/`에 위젯 추가, `src/services/admob_service.dart`에 로드 메서드 추가
2. 프로덕션 배포: `AdMobConfig.isTestMode`를 `false`로 변경, 실제 광고 단위 ID 입력
3. `admob.dart`에 새 export 추가

## 의존성

| 패키지 | 역할 |
|--------|------|
| `core` | Logger |
| `google_mobile_ads` | Google Mobile Ads SDK |
