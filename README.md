# Paginator

A flexible and easy-to-use pagination framework for iOS.

[![Version](https://img.shields.io/cocoapods/v/Pagination.svg?style=flat)](https://cocoapods.org/pods/Pagination)
[![License](https://img.shields.io/cocoapods/l/Pagination.svg?style=flat)](https://cocoapods.org/pods/Pagination)
[![Platform](https://img.shields.io/cocoapods/p/Pagination.svg?style=flat)](https://cocoapods.org/pods/Pagination)

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
  - [CocoaPods](#cocoapods)
  - [Carthage](#carthage)
- [License](#license)

## Overview

`Paginator` is a flexible and easy-to-use pagination framework for iOS applications written in Swift. It provides an efficient way to handle paginated data in scrollable views like `UIScrollView`, `UITableView`, and `UICollectionView`. 

With `Paginator`, you can effortlessly manage pagination in your app by automatically detecting when a user has scrolled close to the end of the current content and triggering the fetching of the next page. The framework supports both vertical and horizontal scrolling and is designed to work seamlessly with various UI components.

### Key Features

- **Automatic Pagination**: Automatically triggers data fetching when the user scrolls near the end of the content.
- **Customizable Scrolling Directions**: Supports vertical and horizontal scrolling directions.
- **Context Management**: Provides a `PaginationContext` to track the state of the pagination (fetching, cancelled, completed, or failed).
- **Delegate Support**: Allows you to customize behavior with a delegate that can manage pagination requests and handle data fetching events.

`Paginator` is designed to integrate smoothly with your existing scrollable views and provides a straightforward way to enhance user experience with efficient and reliable pagination.

## Requirements

- **Swift Version**: This package requires Swift 5.9 or later.
- **iOS Version**: The minimum supported iOS version is iOS 12.0.
- **Xcode**: For building and testing, Xcode 14 or later is recommended.

## Installation

### Swift Package Manager

Paginator is available through [Swift Package Manager](https://swift.org/package-manager/). To install it, add the following line to your `Package.swift` file:

```swift
.package(url: "https://github.com/grighakobian/Paginator.git", from: "0.1.0")
```

### CocoaPods

Paginator is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Pagination', '~> 0.1.0'
```

### Carthage

Paginator is also available through Carthage. To install it, add the following line to your `Cartfile`:

```ruby
github "grighakobian/Paginator" ~> 0.1.0
```

## License

Paginator is available under the MIT license. See the LICENSE file for more info.
