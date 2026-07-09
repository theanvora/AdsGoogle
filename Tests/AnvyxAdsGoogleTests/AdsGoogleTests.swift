//
//  AdsGoogleTests.swift
//  AdsGoogle
//
//  Created by AnhPT on 02/07/2026.
//

import XCTest
import AnvyxAdsCore
@testable import AnvyxAdsGoogle

@MainActor
final class AdsGoogleTests: XCTestCase {
    func testManagerConformsToAbstraction() {
        let manager: AdManaging = GoogleAdsManager(configuration: .test)
        XCTAssertTrue(manager.isEnabled)
    }

    func testDisabledManagerSkipsPresentation() async {
        let manager = GoogleAdsManager(configuration: .test, isEnabled: false)
        let shown = await manager.showInterstitial()
        XCTAssertFalse(shown)
    }
}
