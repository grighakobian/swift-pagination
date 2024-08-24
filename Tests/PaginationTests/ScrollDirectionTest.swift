import XCTest
@testable import Pagination

final class ScrollDirectionTest: XCTestCase {

    func testInsertDirectionMethod() {
        let scrollDirection: PaginationDirection = .left
        scrollDirection.insert(.right)
        XCTAssertTrue(scrollDirection.contains(.left))
        XCTAssertTrue(scrollDirection.contains(.right))
        XCTAssertTrue(scrollDirection.contains(.horizontal))
        XCTAssertFalse(scrollDirection.contains(.vertical))
    }

    func testContainsDirectionMethod() {
        let scrollDirection: PaginationDirection = .vertical
        XCTAssertFalse(scrollDirection.contains(.left))
        XCTAssertFalse(scrollDirection.contains(.right))
        XCTAssertTrue(scrollDirection.contains(.up))
        XCTAssertTrue(scrollDirection.contains(.down))
    }

    func testEquatableConformance() {
        let scrollDirection: PaginationDirection = .left
        XCTAssertTrue(scrollDirection == .left)
        XCTAssertFalse(scrollDirection == .right)
        scrollDirection.insert(.right)
        XCTAssertTrue(scrollDirection == .horizontal)
        XCTAssertFalse(scrollDirection == .vertical)
        XCTAssertFalse(scrollDirection.isEqual(0))
    }

    func testExpressibleByArrayLiteralComformance() {
        let scrollDirection: PaginationDirection = [.up, .down]
        XCTAssertTrue(scrollDirection.contains(.up))
        XCTAssertTrue(scrollDirection.contains(.down))
        XCTAssertTrue(scrollDirection.contains(.vertical))
        XCTAssertFalse(scrollDirection.contains(.left))
        XCTAssertFalse(scrollDirection.contains(.right))
    }
}
