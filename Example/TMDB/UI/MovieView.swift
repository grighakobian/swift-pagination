//
//  MovieView.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 09.11.21.
//

import UIKit

final class MovieView: UIView {
    
    lazy var imageView = makeImageView()
    lazy var ratingLabel = makeRatingLabel()
    
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
   
        let ratingFontAspectRatio: CGFloat = 0.06
        let ratingFontSize = bounds.width * ratingFontAspectRatio
        ratingLabel.font = UIFont.systemFont(ofSize: ratingFontSize, weight: .bold)
    }
    
    private func commonInit() {
        backgroundColor = .secondarySystemFill
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.quaternarySystemFill.cgColor
        
        addSubviews()
        configureImageView()
        configureRatingLabel()
    }
    
    private func addSubviews() {
        addSubview(imageView)
        addSubview(ratingLabel)
    }
    
    private func configureImageView() {
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func configureRatingLabel() {
        ratingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.0).isActive = true
        ratingLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12.0).isActive = true
    }
}


// MARK: - View Factory

extension MovieView {
        
    private func makeRatingLabel()-> UILabel {
        let ratingLabel = UILabel()
        ratingLabel.numberOfLines = 1
        ratingLabel.textColor = UIColor.white
        ratingLabel.backgroundColor = UIColor.systemBlue
        ratingLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        ratingLabel.layer.cornerRadius = 6.0
        ratingLabel.clipsToBounds = true
        ratingLabel.textAlignment = .center
//        ratingLabel.textInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
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
}
