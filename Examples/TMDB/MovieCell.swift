import UIKit

final class MovieCell: UICollectionViewCell {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 15.0
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .secondarySystemFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(imageView)
    clipsToBounds = false
    layer.cornerRadius = 15.0
    layer.shadowRadius = 14.0
    layer.shadowOpacity = 0.22
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 12)
    layer.borderWidth = 2.0
    layer.borderColor = UIColor.quaternarySystemFill.cgColor
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    imageView.image = nil
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.shadowRadius = 0.03 * bounds.width
  }

  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)

    imageView.frame = layoutAttributes.bounds
  }
}
