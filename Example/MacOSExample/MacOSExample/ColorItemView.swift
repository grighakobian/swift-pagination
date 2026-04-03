import AppKit

final class ColorItemView: NSView {
  private let colorView = NSView()
  private let nameLabel = NSTextField(labelWithString: "")

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    colorView.wantsLayer = true
    colorView.layer?.cornerRadius = 12
    colorView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(colorView)

    nameLabel.font = .systemFont(ofSize: 13, weight: .medium)
    nameLabel.alignment = .center
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(nameLabel)

    NSLayoutConstraint.activate([
      colorView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      colorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      colorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
      colorView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -8),

      nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
      nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(with item: ColorItem) {
    colorView.layer?.backgroundColor = item.color.cgColor
    nameLabel.stringValue = item.name
  }
}
