import Foundation

/// Represents the various states a pagination operation can be in.
@objc public enum PaginationState: Int, Sendable {
  /// The pagination operation has started and is currently in progress.
  case started
  /// The pagination operation has successfully completed.
  case completed
  /// The pagination operation has encountered a failure.
  case failed
  /// The pagination operation has been cancelled.
  case cancelled
}
