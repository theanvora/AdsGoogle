// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AdsGoogle",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "AnvyxAdsGoogle", targets: ["AnvyxAdsGoogle"]),
    ],
    dependencies: [
        .package(url: "https://github.com/anvyxhq/AdsKit.git", from: "2.0.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "13.0.0"),
    ],
    targets: [
        .target(
            name: "AnvyxAdsGoogle",
            dependencies: [
                .product(name: "AnvyxAdsCore", package: "AdsKit"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]
        ),
        .testTarget(name: "AnvyxAdsGoogleTests", dependencies: ["AnvyxAdsGoogle"]),
    ]
)
