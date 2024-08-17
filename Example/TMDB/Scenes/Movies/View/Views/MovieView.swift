//
//  MovieView.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 09.11.21.
//

import UIKit

final class MovieView: UIView {
    
    lazy var titleLabel = makeTitleLabel()
    lazy var imageView = makeImageView()
    lazy var ratingLabel = makeRatingLabel()
    lazy var gradientView = makeGradientView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleFontAspectRatio: CGFloat = 0.12
        let titleFontSize = bounds.width * titleFontAspectRatio
        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .heavy)
        
        let ratingFontAspectRatio: CGFloat = 0.06
        let ratingFontSize = bounds.width * ratingFontAspectRatio
        ratingLabel.font = UIFont.systemFont(ofSize: ratingFontSize, weight: .bold)
    }
    
    func bind(item: MovieRepresentable) {
        titleLabel.text = item.title
        imageView.sd_setImage(with: item.posterImageUrl, completed: nil)
        ratingLabel.text = item.averageRating
    }
    
    func prepareForReuse() {
        imageView.image = nil
        imageView.sd_cancelCurrentImageLoad()
    }
    
    private func commonInit() {
        backgroundColor = .secondarySystemFill
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.quaternarySystemFill.cgColor
        
        addSubviews()
        configureImageView()
        configureTitleLabel()
        configureGradientView()
        configureRatingLabel()
    }
    
    private func addSubviews() {
        addSubview(imageView)
        addSubview(gradientView)
        addSubview(titleLabel)
        addSubview(ratingLabel)
    }
    
    private func configureImageView() {
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func configureGradientView() {
        gradientView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
    }
    
    private func configureTitleLabel() {
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24.0).isActive = true
    }
    
    private func configureRatingLabel() {
        ratingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.0).isActive = true
        ratingLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12.0).isActive = true
    }
}


// MARK: - View Factory

extension MovieView {
    
    private func makeTitleLabel()->UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 46, weight: .heavy)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }
    
    private func makeRatingLabel()-> InsetLabel {
        let ratingLabel = InsetLabel()
        ratingLabel.numberOfLines = 1
        ratingLabel.textColor = UIColor.white
        ratingLabel.backgroundColor = UIColor.systemBlue
        ratingLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        ratingLabel.layer.cornerRadius = 6.0
        ratingLabel.clipsToBounds = true
        ratingLabel.textAlignment = .center
        ratingLabel.textInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        return ratingLabel
    }
    
    private func makeImageView()-> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.sd_imageTransition = .fade(duration: 0.2)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }
    
    private func makeGradientView()-> GradientView {
        let gradientView = GradientView()
        gradientView.gradientDirection = .vertical
        let startColor = UIColor.black.withAlphaComponent(0.75)
        let endColor = UIColor.black.withAlphaComponent(0.0)
        gradientView.colors = [endColor, startColor]
        gradientView.clipsToBounds = true
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        return gradientView
    }
}
