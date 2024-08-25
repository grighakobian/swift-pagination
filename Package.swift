// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "Pagination",
  platforms: [
    .iOS(.v12)
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
      path: "Sources/Pagination"
    ),
    .testTarget(
      name: "PaginationTests",
      dependencies: ["Pagination"]
    ),
  ]
)
