import Testing
import UIKit

@testable import Pagination

@Suite("UIScrollView Pagination")
@MainActor
struct UIScrollViewPaginationTests {

  let scrollView = UIScrollView()
  let delegate = SpyPaginationDelegate()

  @Test("Get pagination returns associated instance with scroll view set")
  func getPagination() {
    let pagination = scrollView.pagination
    #expect(pagination.scrollView != nil)
  }

  @Test("Set pagination associates the given instance")
  func setPagination() {
    let pagination = Pagination()
    scrollView.pagination = pagination
    #expect(scrollView.pagination === pagination)
  }

  @Test("Toggle pagination enabled state")
  func togglePaginationEnabled() {
    scrollView.pagination.isEnabled = false
    #expect(!scrollView.pagination.isEnabled)
    scrollView.pagination.isEnabled = true
    #expect(scrollView.pagination.isEnabled)
  }

  @Test("Set and unset pagination delegate")
  func setPaginationDelegate() {
    scrollView.pagination.delegate = delegate
    #expect(scrollView.pagination.delegate != nil)
    scrollView.pagination.delegate = nil
    #expect(scrollView.pagination.delegate == nil)
  }

  @Test("Set pagination direction")
  func setPaginationDirection() {
    scrollView.pagination.direction = .horizontal
    #expect(scrollView.pagination.direction == .horizontal)
    scrollView.pagination.direction = .vertical
    #expect(scrollView.pagination.direction == .vertical)
  }

  @Test("Set pagination leading screens for prefetching")
  func setPaginationLeadingScreens() {
    scrollView.pagination.leadingScreensForPrefetching = 3
    #expect(scrollView.pagination.leadingScreensForPrefetching == 3)
    scrollView.pagination.leadingScreensForPrefetching = 1
    #expect(scrollView.pagination.leadingScreensForPrefetching == 1)
  }
}
