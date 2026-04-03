import Testing
import UIKit

@testable import Pagination

@Suite("UIScrollView Pagination")
@MainActor
struct UIScrollViewPaginationTests {

  let mockScrollView = UIScrollView()
  let mockDelegate = MockPaginationDelegate()

  @Test("Get pagination returns associated instance with scroll view set")
  func getPagination() {
    let pagination = mockScrollView.pagination
    #expect(pagination.scrollView != nil)
  }

  @Test("Set pagination associates the given instance")
  func setPagination() {
    let pagination = Pagination()
    mockScrollView.pagination = pagination
    #expect(mockScrollView.pagination === pagination)
  }

  @Test("Toggle pagination enabled state")
  func togglePaginationEnabled() {
    mockScrollView.pagination.isEnabled = false
    #expect(!mockScrollView.pagination.isEnabled)
    mockScrollView.pagination.isEnabled = true
    #expect(mockScrollView.pagination.isEnabled)
  }

  @Test("Set and unset pagination delegate")
  func setPaginationDelegate() {
    mockScrollView.pagination.delegate = mockDelegate
    #expect(mockScrollView.pagination.delegate != nil)
    mockScrollView.pagination.delegate = nil
    #expect(mockScrollView.pagination.delegate == nil)
  }

  @Test("Set pagination direction")
  func setPaginationDirection() {
    mockScrollView.pagination.direction = .horizontal
    #expect(mockScrollView.pagination.direction == .horizontal)
    mockScrollView.pagination.direction = .vertical
    #expect(mockScrollView.pagination.direction == .vertical)
  }

  @Test("Set pagination leading screens for prefetching")
  func setPaginationLeadingScreens() {
    mockScrollView.pagination.leadingScreensForPrefetching = 3
    #expect(mockScrollView.pagination.leadingScreensForPrefetching == 3)
    mockScrollView.pagination.leadingScreensForPrefetching = 1
    #expect(mockScrollView.pagination.leadingScreensForPrefetching == 1)
  }
}
