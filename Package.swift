// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameEngine",
    products: [
        .library(
            name: "GameEngine",
            targets: ["GameEngine"]),
    ],

    dependencies: [
        .package(url: "https://github.com/ReSwift/ReSwift.git", from: "5.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ],

    targets: [
        .target(
            name: "GameEngine",
            dependencies: [
                "ReSwift"
                ]),
        
        .testTarget(
            name: "GameEngineTests",
            dependencies: [
                "GameEngine",
                "Quick",
                "Nimble"
                ]),
    ]
)
