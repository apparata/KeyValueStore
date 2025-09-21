// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "KeyValueStore",
    platforms: [.iOS(.v18), .macOS(.v15), .visionOS(.v2), .tvOS(.v18)],
    products: [
        .library(
            name: "KeyValueStore",
            targets: ["KeyValueStore"]
        ),
    ],
    targets: [
        .target(
            name: "KeyValueStore"
        ),
        .testTarget(
            name: "KeyValueStoreTests",
            dependencies: ["KeyValueStore"]
        ),
    ]
)
