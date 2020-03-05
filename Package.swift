// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "railcar",
    dependencies: [
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "railcar",
            dependencies: ["AsyncHTTPClient", "NIO", "NIOHTTP1"]),
        .testTarget(
            name: "railcarTests",
            dependencies: ["railcar"]),
    ]
)
