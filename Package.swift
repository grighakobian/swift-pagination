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
            path: "Sources/Paginator"
        ),
        .testTarget(
            name: "PaginatorTests",
            dependencies: ["Paginator"]
        ),
    ]
)
