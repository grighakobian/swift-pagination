import UIKit

final class MockCollectionView: UICollectionView {
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

final class MockCollectionViewLayout: UICollectionViewLayout {
  var _flipsHorizontallyInOppositeLayoutDirection: Bool = true

  override var flipsHorizontallyInOppositeLayoutDirection: Bool {
    return _flipsHorizontallyInOppositeLayoutDirection
  }
}
