// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Paginator",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "Paginator", targets: ["Paginator"]),
    ],
    targets: [
        .target(name: "Paginator", dependencies: [], path: "/Sources")
    ]
)
