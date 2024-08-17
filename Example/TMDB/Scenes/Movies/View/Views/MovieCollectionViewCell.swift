//
//  MovieCollectionViewCell.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import UIKit
import SDWebImage

final class MovieCollectionViewCell: UICollectionViewCell {
    
    private lazy var movieView = makeMovieView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func bind(item: MovieRepresentable) {
        movieView.bind(item: item)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        movieView.prepareForReuse()
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

// MARK: - Interaction

extension MovieCollectionViewCell {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isHighlighted = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isHighlighted = false
    }
    
    override var isHighlighted: Bool {
        didSet { shrink(isHighlighted) }
    }
    
    private func shrink(_ shrink: Bool) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.8,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: { self.transform = shrink ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity },
            completion: nil
        )
    }
}

// MARK: - View Factory

extension MovieCollectionViewCell {
    
    private func makeMovieView()-> MovieView {
        let movieView = MovieView()
        movieView.layer.cornerRadius = 15.0
        movieView.clipsToBounds = true
        movieView.translatesAutoresizingMaskIntoConstraints = false
        return movieView
    }
    
}
