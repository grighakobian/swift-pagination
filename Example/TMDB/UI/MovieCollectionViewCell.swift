//
//  MovieCollectionViewCell.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import SDWebImage
import UIKit

final class MovieCollectionViewCell: UICollectionViewCell {

  private(set) lazy var movieView = makeMovieView()

  override init(frame: CGRect) {
    super.init(frame: frame)

    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    commonInit()
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    movieView.imageView.image = nil
  }

  private func commonInit() {
    configureShadow()
    configureMovieView()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.shadowRadius = 0.03 * bounds.width
  }

  private func configureShadow() {
    layer.cornerRadius = 15.0
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowRadius = 14.0
    layer.shadowOpacity = 0.22
    layer.shadowOffset = CGSize(width: 0, height: 12)
    clipsToBounds = false
  }

  private func configureMovieView() {
    addSubview(movieView)
    movieView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    movieView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    movieView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    movieView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }
}

// MARK: - View Factory

extension MovieCollectionViewCell {

  private func makeMovieView() -> MovieView {
    let movieView = MovieView()
    movieView.layer.cornerRadius = 15.0
    movieView.clipsToBounds = true
    movieView.translatesAutoresizingMaskIntoConstraints = false
    return movieView
  }

}
