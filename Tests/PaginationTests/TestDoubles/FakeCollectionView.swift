#if canImport(UIKit)
import UIKit

final class FakeCollectionView: UICollectionView {
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

final class StubCollectionViewLayout: UICollectionViewLayout {
  var _flipsHorizontallyInOppositeLayoutDirection: Bool = true

  override var flipsHorizontallyInOppositeLayoutDirection: Bool {
    return _flipsHorizontallyInOppositeLayoutDirection
  }
}
#endif
