import Testing

@testable import Pagination

@Suite("PaginationDirection")
struct PaginationDirectionTests {

  @Test("Vertical direction contains up, down, and vertical")
  func verticalDirection() {
    let direction: PaginationDirection = .vertical
    #expect(direction.description == "vertical")
    #expect(!direction.contains(.left))
    #expect(!direction.contains(.right))
    #expect(!direction.contains(.horizontal))
    #expect(direction.contains(.up))
    #expect(direction.contains(.down))
    #expect(direction.contains(.vertical))
  }

  @Test("Horizontal direction contains left, right, and horizontal")
  func horizontalDirection() {
    let direction: PaginationDirection = .horizontal
    #expect(direction.description == "horizontal")
    #expect(direction.contains(.left))
    #expect(direction.contains(.right))
    #expect(direction.contains(.horizontal))
    #expect(!direction.contains(.up))
    #expect(!direction.contains(.down))
    #expect(!direction.contains(.vertical))
  }
}
