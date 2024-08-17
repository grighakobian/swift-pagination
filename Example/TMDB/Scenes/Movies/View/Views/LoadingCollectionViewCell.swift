//
//  LoadingCollectionViewCell.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 09.11.21.
//

import UIKit

final class LoadingCollectionViewCell: UICollectionViewCell {
    
    lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
