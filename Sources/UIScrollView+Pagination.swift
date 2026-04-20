import ObjectiveC

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

/// A key used for associating the `Pagination` instance with a scroll view object.
nonisolated(unsafe) private var paginationKey: UInt8 = 0

/// Extension to add pagination functionality to any scroll view or its subclasses.
extension PlatformScrollView {
  /// The `Pagination` instance associated with the scrollable view.
  ///
  /// This property provides a convenient way to manage pagination for any scroll view.
  ///
  /// - Note: The `Pagination` instance monitors the scroll view's content offset to determine when to request additional data.
  /// This is particularly useful when implementing infinite scrolling or batch data loading in large lists.
  ///
  /// > Warning: It is mandatory to call `context.finish(_:)` with either `true` or `false` once the data loading is complete, to accurately reflect the pagination state.
  @objc public var pagination: Pagination {
    get {
      if let pagination = objc_getAssociatedObject(self, &paginationKey) as? Pagination {
        return pagination
      } else {
        let pagination = Pagination()
        pagination.scrollView = self
        objc_setAssociatedObject(
          self, &paginationKey, pagination, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return pagination
      }
    }
    set {
      newValue.scrollView = self
      objc_setAssociatedObject(self, &paginationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
