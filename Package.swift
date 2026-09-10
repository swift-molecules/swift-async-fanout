// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-async-fanout",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Async Fanout", targets: ["Async Fanout"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-async.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Async Fanout",
            dependencies: [
                .product(name: "Async", package: "swift-async"),
            ],
            path: "Sources/Async Fanout"
        ),
        .testTarget(
            name: "Async Fanout Tests",
            dependencies: [
                .product(name: "Async", package: "swift-async"),
                .target(name: "Async Fanout"),
            ],
            path: "Tests/Async Fanout Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
