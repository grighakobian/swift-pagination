import XCTest

@testable import Pagination

final class PaginationDirectionTests: XCTestCase {

  func testInsertDirectionMethod() {
    var paginationDirection: ScrollDirection = .left
    paginationDirection.insert(.right)
    XCTAssertTrue(paginationDirection.contains(.left))
    XCTAssertTrue(paginationDirection.contains(.right))
    XCTAssertTrue(paginationDirection.contains(.horizontal))
    XCTAssertFalse(paginationDirection.contains(.vertical))
  }

  func testContainsDirectionMethod() {
    let paginationDirection: ScrollDirection = .vertical
    XCTAssertFalse(paginationDirection.contains(.left))
    XCTAssertFalse(paginationDirection.contains(.right))
    XCTAssertTrue(paginationDirection.contains(.up))
    XCTAssertTrue(paginationDirection.contains(.down))
  }

  func testEquatableConformance() {
    var paginationDirection: ScrollDirection = .left
    XCTAssertTrue(paginationDirection == .left)
    XCTAssertFalse(paginationDirection == .right)
    paginationDirection.insert(.right)
    XCTAssertTrue(paginationDirection == .horizontal)
    XCTAssertFalse(paginationDirection == .vertical)
  }
}
