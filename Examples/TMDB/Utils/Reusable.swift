//
//  Reusable.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 09.11.21.
//

import UIKit

protocol Reusable {
  static var reuseID: String { get }
}

extension Reusable {

  static var reuseID: String {
    return String(describing: self)
  }
}

// MARK: - UICollectionViewCell + Reusable

extension UICollectionViewCell: Reusable {}

extension UICollectionView {

  func dequeueReusableCell<T>(ofType cellType: T.Type = T.self, at indexPath: IndexPath) -> T
  where T: UICollectionViewCell {
    let cell = dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath)
    guard let cell = cell as? T else {
      fatalError()
    }
    return cell
  }

  func register(_ cell: UICollectionViewCell.Type) {
    register(cell, forCellWithReuseIdentifier: cell.reuseID)
  }
}
