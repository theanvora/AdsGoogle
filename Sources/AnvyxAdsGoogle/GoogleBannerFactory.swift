//
//  GoogleBannerFactory.swift
//  AdsGoogle
//
//  Created by AnhPT on 02/07/2026.
//

import UIKit
import AnvyxAdsCore
@preconcurrency import GoogleMobileAds

/// Builds an AdMob banner `UIView` for use with `AdsCore.BannerAdView`.
///
/// ```swift
/// BannerAdView { GoogleBannerFactory.make(unitID: AdConfiguration.test.bannerID!) }
///     .frame(height: 50)
/// ```
@MainActor
public enum GoogleBannerFactory {
    public static func make(unitID: String, rootViewController: UIViewController? = nil) -> UIView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = unitID
        banner.rootViewController = rootViewController ?? UIApplication.shared.keyWindowRootViewController
        banner.load(Request())
        return banner
    }
}

extension UIApplication {
    var keyWindowRootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
