import UIKit

/// A simple collection view cell displaying a color swatch with a label.
public final class ColorCell: UICollectionViewCell {
  public static let reuseIdentifier = "ColorCell"

  private let colorView = UIView()
  private let nameLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)

    colorView.layer.cornerRadius = 12
    colorView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(colorView)

    nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
    nameLabel.textColor = .label
    nameLabel.textAlignment = .center
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(nameLabel)

    NSLayoutConstraint.activate([
      colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
      colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      colorView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -8),

      nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      nameLabel.heightAnchor.constraint(equalToConstant: 20),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(with color: Color) {
    colorView.backgroundColor = color.color
    nameLabel.text = color.name
  }
}
