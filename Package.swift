// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "Pagination",
  platforms: [
    .iOS(.v13),
    .macOS(.v11),
  ],
  products: [
    .library(
      name: "Pagination",
      targets: ["Pagination"]
    )
  ],
  targets: [
    .target(
      name: "Pagination",
      path: "Sources"
    ),
    .testTarget(
      name: "PaginationTests",
      dependencies: ["Pagination"],
      path: "Tests"
    ),
  ]
)
