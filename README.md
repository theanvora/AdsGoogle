# AdsGoogle

The Google Mobile Ads (AdMob) adapter for [AdsKit](https://github.com/anvyxhq/AdsKit).
It implements `AdsCore`'s provider-agnostic protocols, so your screens depend only
on `AdManaging` while the SDK stays isolated here.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/iOS-26%2B-blue.svg)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

## Features

- **`GoogleAdsManager`** — implements `AdManaging`, `AppOpenAdManaging`, and
  `AdEventPublishing` (Combine) on top of Google Mobile Ads **v13** (modern,
  prefix-free API: `MobileAds`, `InterstitialAd`, `RewardedAd`, `AppOpenAd`).
- **`GoogleBannerFactory`** — produces a banner `UIView` for `AdsCore.BannerAdView`.
- `async/await` loading & presentation; lifecycle delivered as Combine `AdEvent`s.

## Installation

```swift
.package(url: "https://github.com/anvyxhq/AdsGoogle.git", from: "1.0.0")
```

This transitively pulls in `AdsKit` (the `AdsCore` abstraction) and the Google
Mobile Ads SDK. Add your AdMob **App ID** to `Info.plist` (`GADApplicationIdentifier`).

## Usage

```swift
import AdsCore
import AdsGoogle

// Off for premium users, AdMob otherwise — both are `AdManaging`.
let ads: AdManaging = isPremium ? NullAdsManager()
                                : GoogleAdsManager(configuration: .test)
ads.start()

await ads.loadInterstitial()
await ads.showInterstitial()

if let reward = await ads.showRewarded() {
    grant(reward.amount)
}

// React to lifecycle via Combine
(ads as? AdEventPublishing)?.events
    .filter { $0 == .dismissed(.interstitial) }
    .sink { _ in resumeGame() }
    .store(in: &cancellables)

// Banner in SwiftUI
BannerAdView { GoogleBannerFactory.make(unitID: AdConfiguration.test.bannerID!) }
    .frame(height: 50)
```

## Requirements

- iOS 26.0+ · Swift 5.9+ · Google Mobile Ads SDK 13+

## License

MIT
