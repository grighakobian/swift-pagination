import UIKit

final class MockScrollView: UIScrollView {
  var isVisible: Bool = true
  var _contentOffset: CGPoint = .zero

  override var window: UIWindow? {
    isVisible ? UIWindow() : nil
  }

  override var contentOffset: CGPoint {
    get {
      return _contentOffset
    }
    set {
      willChangeValue(for: \.contentOffset)
      _contentOffset = newValue
      didChangeValue(for: \.contentOffset)
    }
  }

  override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
    self.contentOffset = contentOffset
  }
}
