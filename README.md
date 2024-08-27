<img src="/.github/resources/preview.png" alt="Pagination" style="width: 100%; height: auto;">

#

A flexible and easy-to-use pagination framework inspired by [Texture](https://github.com/TextureGroup/Texture) batch fetching API.

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)

## Overview

`Paginator` is a flexible and easy-to-use pagination framework for iOS applications written in Swift. It provides an efficient way to handle paginated data in scrollable views like `UIScrollView`, `UITableView`, and `UICollectionView`.

## Features

- Supports both vertical and horizontal scroll directions.
- Easily integrates with `UIScrollView`, `UITableView`, and `UICollectionView`.
- Provides customizable batching settings.
- **Objective-C Support**: Paginator supports Objective-C, allowing integration in projects written in Objective-C.

With `Paginator`, you can effortlessly manage pagination in your app by automatically detecting when a user has scrolled close to the end of the current content and triggering the fetching of the next page. The framework supports both vertical and horizontal scrolling and is designed to work seamlessly with various UI components.


## Installation

You can add pagination to an Xcode project by adding it as a package dependency.

> https://github.com/grighakobian/Paginator

If you want to use Pagination in a SwiftPM project, it's as simple as adding it to a dependencies clause in your Package.swift:

``` swift
dependencies: [
  .package(url: "https://github.com/grighakobian/Paginator", from: "1.0.0")
]
```

### Example Usage

Example usage in Swift.

```swift
collectionView.pagination.isEnabled = true
// Configure the pagination direction. Defaults to .vertical.
collectionView.pagination.direction = .horizontal
// Configure leading screens for prefetching.
collectionView.pagination.leadingScreensForPrefetching = 3
// Set the delegate to receive updates.
collectionView.pagination.delegate = self
```

Handle pagination delegate.

```swift
func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext) {
    Task {
      do {
        let nextPage = currentPage + 1
        let moviesResult = try await moviesService.getPopularMovies(page: nextPage)
        self.updateMovies(with: moviesResult)
        self.currentPage = nextPage
        if let totalPages = moviesResult.totalPages {
          pagination.isEnabled = self.currentPage < totalPages
        }
        context.finish(true)
      } catch {
        context.finish(false)
      }
    }
}
```

> [!IMPORTANT]
> It is mandatory to call `context.finish(_:)` once the data loading is complete, to accurately reflect the pagination state.

Pagination is fully compatible with Objective-C
```objc
self.tableView.pagination.isEnabled = YES;
self.tableView.pagination.direction = PaginationDirectionVertical;
self.tableView.pagination.delegate = self;
```

Handle the paginatio delegate.

## License

Paginator is available under the MIT license. See the LICENSE file for more info.
