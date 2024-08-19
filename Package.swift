// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Paginator",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "Paginator",
            targets: ["Paginator"]
        ),
    ],
    targets: [
        .target(
            name: "Paginator",
            dependencies: ["ScrollDirection"],
            path: "Sources/Paginator"
        ),
        .target(
            name: "ScrollDirection",
            path: "Sources/ScrollDirection",
            publicHeadersPath: "include"
        ),
        .testTarget(
            name: "PaginatorTests",
            dependencies: ["Paginator"]
        ),
    ]
)
