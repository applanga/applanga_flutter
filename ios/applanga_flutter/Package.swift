// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "applanga_flutter",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "applanga-flutter", targets: ["applanga_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/applanga/sdk-ios.git", exact: "2.0.218"),
    ],
    targets: [
        .target(
            name: "applanga_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Applanga", package: "sdk-ios"),
            ],
            cSettings: [
                .headerSearchPath("include/applanga_flutter")
            ]
        )
    ]
)
