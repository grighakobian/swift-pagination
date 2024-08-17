// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Networking",
            targets: ["Networking"])
    ],
    dependencies: [
            .package(path: "../Domain"),
            .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),
            .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.7.1")
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Networking",
            dependencies: [
                "Domain",
                .product(name: "Moya", package: "Moya"),
                .product(name: "RxMoya", package: "Moya"),
                .product(name: "RxSwift", package: "RxSwift"),
            ]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]),
    ]
)
