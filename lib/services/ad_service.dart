import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Demo ad unit IDs (replace with your actual ad unit IDs)
  static const String _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // Demo banner ad
      : 'ca-app-pub-3940256099942544/6300978111'; // Replace with your actual ID

  static const String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Demo interstitial ad
      : 'ca-app-pub-3940256099942544/1033173712'; // Replace with your actual ID

  static const String _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // Demo rewarded ad
      : 'ca-app-pub-3940256099942544/5224354917'; // Replace with your actual ID

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool get isBannerAdReady => _bannerAd != null;
  bool get isInterstitialAdReady => _interstitialAd != null;
  bool get isRewardedAdReady => _rewardedAd != null;

  BannerAd? get bannerAd => _bannerAd;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          _bannerAd = null;
        },
        onAdOpened: (ad) {
          debugPrint('Banner ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('Banner ad closed');
        },
      ),
    );

    _bannerAd!.load();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad loaded');
          _interstitialAd = ad;
          
          _interstitialAd!.setImmersiveMode(true);
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('Interstitial ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Interstitial ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded ad loaded');
          _rewardedAd = ad;
          
          _rewardedAd!.setImmersiveMode(true);
          
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('Rewarded ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Rewarded ad dismissed');
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Rewarded ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint('Interstitial ad not ready');
      loadInterstitialAd(); // Try to load if not available
    }
  }

  void showRewardedAd({required Function(AdWithoutView, RewardItem) onUserEarnedReward}) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
    } else {
      debugPrint('Rewarded ad not ready');
      loadRewardedAd(); // Try to load if not available
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
  }
}

// Widget for displaying banner ads
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    AdService().loadBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    if (AdService().isBannerAdReady) {
      return Container(
        alignment: Alignment.center,
        width: AdService().bannerAd!.size.width.toDouble(),
        height: AdService().bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: AdService().bannerAd!),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

// Mixin for ads functionality
mixin AdMixin {
  void initializeAds() {
    AdService().loadBannerAd();
    AdService().loadInterstitialAd();
    AdService().loadRewardedAd();
  }

  void showInterstitialAd() {
    AdService().showInterstitialAd();
  }

  void showRewardedAd({required Function(AdWithoutView, RewardItem) onUserEarnedReward}) {
    AdService().showRewardedAd(onUserEarnedReward: onUserEarnedReward);
  }

  void disposeAds() {
    AdService().dispose();
  }
}
