import 'package:speaking_english_with_ai/helper/my_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Import để kiểm tra nền tảng
import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AdHelper {
  static void init() {
    if (!kIsWeb) {
      EasyAudienceNetwork.init(testMode: true);
    }
  }

  static void showInterstitialAd(VoidCallback onComplete) {
    if (kIsWeb) {
      onComplete(); // Trên Web, gọi trực tiếp onComplete()
      return;
    }

    MyDialog.showLoadingDialog();

    final interstitialAd = InterstitialAd(InterstitialAd.testPlacementId);

    interstitialAd.listener = InterstitialAdListener(
      onLoaded: () {
        Get.back();
        onComplete();
        interstitialAd.show();
      },
      onDismissed: () {
        interstitialAd.destroy();
      },
      onError: (code, errorMessage) {
        Get.back();
        onComplete();
        print('Interstitial Ad Error: $errorMessage');
      },
    );

    interstitialAd.load();
  }

  static Widget nativeAd() {
    if (kIsWeb) {
      return const SizedBox
          .shrink(); // Return an empty widget instead of fixed height
    }

    return SafeArea(
      child: NativeAd(
        placementId: NativeAd.testPlacementId,
        adType: NativeAdType.NATIVE_AD,
        keepExpandedWhileLoading: false,
        expandAnimationDuraion: 1000,
        listener: NativeAdListener(
          onError: (code, message) => print('Native Ad Error: $message'),
          onLoaded: () => print('Native Ad Loaded'),
          onClicked: () => print('Native Ad Clicked'),
          onLoggingImpression: () => print('Native Ad Impression Logged'),
          onMediaDownloaded: () => print('Native Ad Media Downloaded'),
        ),
      ),
    );
  }

  static Widget nativeBannerAd() {
    if (kIsWeb) {
      return const SizedBox
          .shrink(); // Return an empty widget instead of fixed height
    }

    return SafeArea(
      child: NativeAd(
        placementId: NativeAd.testPlacementId,
        adType: NativeAdType.NATIVE_BANNER_AD,
        bannerAdSize: NativeBannerAdSize.HEIGHT_100,
        keepExpandedWhileLoading: false,
        height: 100,
        expandAnimationDuraion: 1000,
        listener: NativeAdListener(
          onError: (code, message) => print('Native Banner Ad Error: $message'),
          onLoaded: () => print('Native Banner Ad Loaded'),
          onClicked: () => print('Native Banner Ad Clicked'),
          onLoggingImpression: () =>
              print('Native Banner Ad Impression Logged'),
          onMediaDownloaded: () => print('Native Banner Ad Media Downloaded'),
        ),
      ),
    );
  }
}
