import Foundation

extension PaginationContext {

  @available(*, deprecated, renamed: "PaginationState")
  public typealias State = PaginationState

  @available(*, deprecated, renamed: "isStarted")
  public var isFetching: Bool { isStarted }

  @available(
    *, deprecated, renamed: "update(state:)", message: "Use update(state: .started) instead."
  )
  @objc public func start() {
    update(state: .started)
  }

  @available(
    *, deprecated, renamed: "update(state:)", message: "Use update(state: .cancelled) instead."
  )
  @objc public func cancel() {
    update(state: .cancelled)
  }

  @available(
    *, deprecated, renamed: "update(state:)",
    message: "Use update(state: .completed) or update(state: .failed) instead."
  )
  @objc public func finish(_ isCompleted: Bool) {
    update(state: isCompleted ? .completed : .failed)
  }
}
