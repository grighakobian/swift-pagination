import XCTest
@testable import Pagination

final class PaginationDirectionTests: XCTestCase {

    func testInsertDirectionMethod() {
        let paginationDirection: PaginationDirection = .left
        paginationDirection.insert(.right)
        XCTAssertTrue(paginationDirection.contains(.left))
        XCTAssertTrue(paginationDirection.contains(.right))
        XCTAssertTrue(paginationDirection.contains(.horizontal))
        XCTAssertFalse(paginationDirection.contains(.vertical))
    }

    func testContainsDirectionMethod() {
        let paginationDirection: PaginationDirection = .vertical
        XCTAssertFalse(paginationDirection.contains(.left))
        XCTAssertFalse(paginationDirection.contains(.right))
        XCTAssertTrue(paginationDirection.contains(.up))
        XCTAssertTrue(paginationDirection.contains(.down))
    }

    func testEquatableConformance() {
        let paginationDirection: PaginationDirection = .left
        XCTAssertTrue(paginationDirection == .left)
        XCTAssertFalse(paginationDirection == .right)
        paginationDirection.insert(.right)
        XCTAssertTrue(paginationDirection == .horizontal)
        XCTAssertFalse(paginationDirection == .vertical)
        XCTAssertFalse(paginationDirection.isEqual(0))
    }

    func testConvenienceInit() {
        var direction = PaginationDirection(oldOffset: CGPoint(x: 0, y: 200), newOffset: .zero)
        XCTAssertTrue(direction == .up)
        direction = PaginationDirection(oldOffset: .zero, newOffset: CGPoint(x: 0, y: 200))
        XCTAssertTrue(direction == .down)
        direction = PaginationDirection(oldOffset: .zero, newOffset: CGPoint(x: 200, y: 0))
        XCTAssertTrue(direction == .right)
        direction = PaginationDirection(oldOffset: CGPoint(x: 200, y: 0), newOffset: .zero)
        XCTAssertTrue(direction == .left)
    }
}
