<img src="/.github/resources/preview.png" alt="Pagination" style="width: 100%; height: auto;">

#

A flexible and easy-to-use pagination framework inspired by [Texture](https://github.com/TextureGroup/Texture) batch fetching API.

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)

## Overview

`Pagination` provides an easy-to-use API for implementing infinite scrolling in your applications. It allows seamless integration of pagination functionality in any scrollable view, whether it's a `UITableView`, `UICollectionView`, or any other scrollable container.

With `Pagination`, you can effortlessly manage pagination in your app by automatically detecting when a user has scrolled close to the end of the current content and triggering the fetching of the next page. The framework supports both vertical and horizontal scrolling and is designed to work seamlessly with various UI components.

### Features

- Easily integrates with `UIScrollView`, `UITableView`, and `UICollectionView`.
- Supports both vertical and horizontal scroll directions.
- Provides customizable prefetching distance to control when the next batch of data is fetched.
- **Objective-C Support**: Fully compatible with Objective-C projects, making it easier to integrate into existing codebases.

### Getting Started

Implementing infinite scrolling is straightforward, especially with vertical scrolling. Set up the delegate to handle requests for new page prefetching

```swift
collectionView.pagination.delegate = self
```

Implement the delegate method to fetch data for the new page

```swift
func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext) {
    // Fetch the next page of data from your source
    fetchData(forPage: nextPage) { result in
        switch result {
        case .success(let data):
            // Successfully fetched data
            context.finish(true)
        case .failure:
            // Failed to fetch data
            context.finish(false)
        }
    }
}
```

> [!IMPORTANT]
> It is essential to call `context.finish(_:)` once the data loading is complete to accurately update the pagination state.

To disable pagination, set the `isEnabled` property to `false`. This will stop pagination from monitoring the scrollable view

```swift
pagination.isEnabled = false
```

For horizontal scrolling, configure pagination to handle horizontal scroll

```swift
collectionView.pagination.direction = .horizontal
```

To adjust the prefetching distance, set the `leadingScreensForPrefetching` property to your desired value. The default is `2` leading screens. Setting it to `0` will stop pagination from notifying you about new data prefetching

```swift
collectionView.pagination.leadingScreensForPrefetching = 3
```

### Objective-C Integration

[!NOTE] `Pagination` is fully compatible with Objective-C projects. Simply import the module and use the provided APIs.

```objc
self.tableView.pagination.isEnabled = YES;
self.tableView.pagination.direction = PaginationDirectionVertical;
self.tableView.pagination.delegate = self;
```

### Examples

Check out the Example directory to see how to use Pagination in real-world scenarios.

## Installation

You can add pagination to an Xcode project by adding it as a package dependency.

> https://github.com/grighakobian/Paginator

If you want to use Pagination in a SwiftPM project, it's as simple as adding it to a dependencies clause in your Package.swift:

``` swift
dependencies: [
  .package(url: "https://github.com/grighakobian/Paginator", from: "1.0.0")
]
```

## License

Paginator is available under the MIT license. See the LICENSE file for more info.
