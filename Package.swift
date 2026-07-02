// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AdsGoogle",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .library(name: "AdsGoogle", targets: ["AdsGoogle"]),
    ],
    dependencies: [
        .package(url: "https://github.com/anvyxhq/AdsKit.git", from: "1.2.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "13.0.0"),
    ],
    targets: [
        .target(
            name: "AdsGoogle",
            dependencies: [
                .product(name: "AdsCore", package: "AdsKit"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]
        ),
        .testTarget(
            name: "AdsGoogleTests",
            dependencies: ["AdsGoogle"]
        ),
    ]
)
