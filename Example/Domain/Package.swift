// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.7.1")
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift")
            ]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"])
    ]
)
