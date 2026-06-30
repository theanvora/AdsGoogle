//
//  GoogleAdsManager.swift
//  AdsGoogle
//
//  Created by AnhPT on 02/07/2026.
//

import AdsCore
import Combine
import UIKit
@preconcurrency import GoogleMobileAds

/// Google Mobile Ads (AdMob) implementation of `AdsCore`'s protocols. Screens
/// keep depending only on `AdManaging` / `AppOpenAdManaging`; the SDK lives here.
///
/// ```swift
/// let ads = GoogleAdsManager(configuration: .test)
/// ads.start()
/// await ads.loadInterstitial()
/// await ads.showInterstitial()
/// ```
@MainActor
public final class GoogleAdsManager: NSObject, AdManaging, AdEventPublishing, AppOpenAdManaging {
    public var isEnabled: Bool

    private let configuration: AdConfiguration
    private let eventsSubject = PassthroughSubject<AdEvent, Never>()

    private var interstitial: InterstitialAd?
    private var rewarded: RewardedAd?
    private var appOpen: AppOpenAd?

    private var currentFormat: AdsCore.AdFormat = .interstitial
    private var pendingReward: AdsCore.AdReward?
    private var rewardContinuation: CheckedContinuation<AdsCore.AdReward?, Never>?

    public init(configuration: AdConfiguration, isEnabled: Bool = true) {
        self.configuration = configuration
        self.isEnabled = isEnabled
        super.init()
    }

    /// Combine stream of ad lifecycle events.
    public var events: AnyPublisher<AdEvent, Never> {
        eventsSubject.eraseToAnyPublisher()
    }

    public func start() {
        MobileAds.shared.start(completionHandler: nil)
    }

    // MARK: - Interstitial

    public func loadInterstitial() async {
        guard isEnabled, let id = configuration.interstitialID else { return }
        do {
            let ad = try await InterstitialAd.load(with: id, request: Request())
            ad.fullScreenContentDelegate = self
            interstitial = ad
            eventsSubject.send(.loaded(.interstitial))
        } catch {
            eventsSubject.send(.failed(.interstitial, reason: error.localizedDescription))
        }
    }

    @discardableResult
    public func showInterstitial() async -> Bool {
        guard isEnabled, let ad = interstitial else { return false }
        currentFormat = .interstitial
        ad.present(from: nil)
        interstitial = nil
        return true
    }

    // MARK: - Rewarded

    public func loadRewarded() async {
        guard isEnabled, let id = configuration.rewardedID else { return }
        do {
            let ad = try await RewardedAd.load(with: id, request: Request())
            ad.fullScreenContentDelegate = self
            rewarded = ad
            eventsSubject.send(.loaded(.rewarded))
        } catch {
            eventsSubject.send(.failed(.rewarded, reason: error.localizedDescription))
        }
    }

    public func showRewarded() async -> AdsCore.AdReward? {
        guard isEnabled, let ad = rewarded else { return nil }
        currentFormat = .rewarded
        pendingReward = nil
        return await withCheckedContinuation { continuation in
            rewardContinuation = continuation
            ad.present(from: nil) { [weak self] in
                let earned = ad.adReward
                let reward = AdsCore.AdReward(amount: earned.amount.intValue, type: earned.type)
                self?.pendingReward = reward
                self?.eventsSubject.send(.rewarded(reward))
            }
            rewarded = nil
        }
    }

    // MARK: - App Open

    public func loadAppOpenAd() async {
        guard isEnabled, let id = configuration.appOpenID else { return }
        do {
            let ad = try await AppOpenAd.load(with: id, request: Request())
            ad.fullScreenContentDelegate = self
            appOpen = ad
        } catch {
            eventsSubject.send(.failed(.appOpen, reason: error.localizedDescription))
        }
    }

    @discardableResult
    public func showAppOpenAdIfAvailable() async -> Bool {
        guard isEnabled, let ad = appOpen else { return false }
        currentFormat = .appOpen
        ad.present(from: nil)
        appOpen = nil
        return true
    }

    private func finishReward() {
        rewardContinuation?.resume(returning: pendingReward)
        rewardContinuation = nil
        pendingReward = nil
    }
}

// MARK: - FullScreenContentDelegate

extension GoogleAdsManager: FullScreenContentDelegate {
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        eventsSubject.send(.shown(currentFormat))
    }

    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        eventsSubject.send(.clicked(currentFormat))
    }

    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        eventsSubject.send(.dismissed(currentFormat))
        if rewardContinuation != nil { finishReward() }
    }

    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        eventsSubject.send(.failed(currentFormat, reason: error.localizedDescription))
        if rewardContinuation != nil { finishReward() }
    }
}
