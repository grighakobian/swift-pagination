//
//  MovieDetailViewController+ViewFactory.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 10.11.21.
//

import UIKit

// MARK:-  View Factory

extension MovieDetailViewController {
    
    func makeStackView()-> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func makeMovieView()-> MovieView {
        let movieView = MovieView()
        movieView.clipsToBounds = true
        movieView.translatesAutoresizingMaskIntoConstraints = false
        return movieView
    }
    
    func makeOverviewLabel()-> InsetLabel {
        let overviewLabel = InsetLabel()
        overviewLabel.numberOfLines = 0
        overviewLabel.textColor = UIColor.secondaryLabel
        overviewLabel.font = UIFont.systemFont(ofSize: 32, weight: .regular)
        overviewLabel.textInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        return overviewLabel
    }
    
    func makeScrollView()-> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }
    
    func makeContainerView()-> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        return containerView
    }
    
    func makeHeadingLabel()-> InsetLabel {
        let label = InsetLabel()
        label.text = "You may also like"
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        label.textInsets = UIEdgeInsets(top: 8, left: 20, bottom: 18, right: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func makeCollectionView()-> UICollectionView {
        let layout = MoviesCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 250, height: 300)
        layout.minimumLineSpacing = 20.0
        layout.minimumInteritemSpacing = 20.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .quaternarySystemFill
        collectionView.register(MovieCollectionViewCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }
}
