import XCTest
@testable import Pagination

final class PaginationDirectionTests: XCTestCase {

  func testVerticalDirection() {
    let paginationDirection: PaginationDirection = .vertical
    XCTAssertTrue(paginationDirection.description == "vertical")
    XCTAssertFalse(paginationDirection.contains(.left))
    XCTAssertFalse(paginationDirection.contains(.right))
    XCTAssertFalse(paginationDirection.contains(.horizontal))
    XCTAssertTrue(paginationDirection.contains(.up))
    XCTAssertTrue(paginationDirection.contains(.down))
    XCTAssertTrue(paginationDirection.contains(.vertical))
  }

  func testHorzontalDirection() {
    let paginationDirection: PaginationDirection = .horizontal
    XCTAssertTrue(paginationDirection.description == "horizontal")
    XCTAssertTrue(paginationDirection.contains(.left))
    XCTAssertTrue(paginationDirection.contains(.right))
    XCTAssertTrue(paginationDirection.contains(.horizontal))
    XCTAssertFalse(paginationDirection.contains(.up))
    XCTAssertFalse(paginationDirection.contains(.down))
    XCTAssertFalse(paginationDirection.contains(.vertical))
  }
}
