# Paginator

A flexible and easy-to-use pagination framework for iOS.

[![License](https://img.shields.io/cocoapods/l/Pagination.svg?style=flat)](https://cocoapods.org/pods/Pagination)
[![Platform](https://img.shields.io/cocoapods/p/Pagination.svg?style=flat)](https://cocoapods.org/pods/Pagination)

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)

## Overview

`Paginator` is a flexible and easy-to-use pagination framework for iOS applications written in Swift. It provides an efficient way to handle paginated data in scrollable views like `UIScrollView`, `UITableView`, and `UICollectionView`. 

With `Paginator`, you can effortlessly manage pagination in your app by automatically detecting when a user has scrolled close to the end of the current content and triggering the fetching of the next page. The framework supports both vertical and horizontal scrolling and is designed to work seamlessly with various UI components.

## Requirements

- **Swift Version**: Swift 5.9 or later.
- **iOS Version**: iOS 12.0 or later.
- **Xcode**: Xcode 14 or later.

## Installation

### Swift Package Manager

Paginator is available through [Swift Package Manager](https://swift.org/package-manager/). To install it, add the following line to your `Package.swift` file:

```swift
.package(url: "https://github.com/grighakobian/Paginator.git", from: "1.0.0")
```

### Example Usage

```swift
import UIKit
import Paginator
   
class FeedViewController: UICollectionViewController {
    private let paginator = Paginator()
    private var currentPage = 0
    private var isPagingEnabled = true
   
    override func viewDidLoad() {
        super.viewDidLoad()

        paginator.delegate = self
        paginator.attach(to: collectionView)
    }
}

// MARK: - PaginatorDelegate
   
extension FeedViewController: PaginatorDelegate {
   
    func paginator(_ paginator: Paginator, shouldRequestNextPageWith context: PaginationContext) -> Bool {
        return isPagingEnabled
    }
   
    func paginator(_ paginator: Paginator, didRequestNextPageWith context: PaginationContext) {
        context.start()
        let nextPage = currentPage + 1
        feedProvider.provideFeed(page: nextPage, pageSize: 20) { [weak self] result in
            switch result {
            case .success(let newFeed):
                self?.currentPage = nextPage
                self?.isPagingEnabled = nextPage < newFeed.totalPages
                self?.reload(using: newFeed)
                context.finish(true)
            case .failure(let error):
                context.finish(false)
            }
        }
    }
}
```

## License

Paginator is available under the MIT license. See the LICENSE file for more info.