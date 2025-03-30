import 'dart:developer';

import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'my_dialog.dart';

/// A helper class to manage advertisements using EasyAudienceNetwork.
class AdHelper {
  /// Initializes the EasyAudienceNetwork SDK.
  /// Ensure to disable `testMode` before publishing the app live.
  static void init() {
    EasyAudienceNetwork.init(
      testMode: true, // Set to false when releasing the app
    );
  }

  /// Displays an interstitial ad and executes [onComplete] when done.
  /// Shows a loading dialog while the ad is loading.
  ///
  /// - If the ad loads successfully, it is displayed.
  /// - If there is an error, it logs the error and executes `onComplete`.
  static void showInterstitialAd(VoidCallback onComplete) {
    // Show loading dialog
    MyDialog.showLoadingDialog();

    final interstitialAd = InterstitialAd(InterstitialAd.testPlacementId);

    interstitialAd.listener = InterstitialAdListener(
      onLoaded: () {
        // Hide loading dialog
        Get.back();
        onComplete();

        // Show the ad
        interstitialAd.show();
      },
      onDismissed: () {
        // Clean up the ad instance
        interstitialAd.destroy();
      },
      onError: (code, errorMessage) {
        // Hide loading dialog
        Get.back();
        onComplete();

        // Log the error message
        log('Interstitial Ad Error: $errorMessage');
      },
    );

    // Load the interstitial ad
    interstitialAd.load();
  }

  /// Returns a **Native Ad widget** wrapped in `SafeArea`.
  ///
  /// - Displays a native ad with the given `placementId`.
  /// - Listens for events like loaded, clicked, or errors.
  static Widget nativeAd() {
    return SafeArea(
      child: NativeAd(
        placementId: NativeAd.testPlacementId,
        adType: NativeAdType.NATIVE_AD,
        keepExpandedWhileLoading: false,
        expandAnimationDuraion: 1000,
        listener: NativeAdListener(
          onError: (code, message) => log('Native Ad Error: $message'),
          onLoaded: () => log('Native Ad Loaded'),
          onClicked: () => log('Native Ad Clicked'),
          onLoggingImpression: () => log('Native Ad Impression Logged'),
          onMediaDownloaded: () => log('Native Ad Media Downloaded'),
        ),
      ),
    );
  }

  /// Returns a **Native Banner Ad widget** wrapped in `SafeArea`.
  ///
  /// - Displays a **native banner ad** with a height of `100px`.
  /// - Listens for events such as loading, clicking, and errors.
  static Widget nativeBannerAd() {
    return SafeArea(
      child: NativeAd(
        placementId: NativeAd.testPlacementId,
        adType: NativeAdType.NATIVE_BANNER_AD,
        bannerAdSize: NativeBannerAdSize.HEIGHT_100,
        keepExpandedWhileLoading: false,
        height: 100,
        expandAnimationDuraion: 1000,
        listener: NativeAdListener(
          onError: (code, message) => log('Native Banner Ad Error: $message'),
          onLoaded: () => log('Native Banner Ad Loaded'),
          onClicked: () => log('Native Banner Ad Clicked'),
          onLoggingImpression: () => log('Native Banner Ad Impression Logged'),
          onMediaDownloaded: () => log('Native Banner Ad Media Downloaded'),
        ),
      ),
    );
  }
}
