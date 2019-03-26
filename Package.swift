// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Socket",
    products: [
        .library(
            name: "Socket",
            targets: ["Socket"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Socket",
            dependencies: []),
        .testTarget(
            name: "SocketTests",
            dependencies: ["Socket"]),
    ]
)
