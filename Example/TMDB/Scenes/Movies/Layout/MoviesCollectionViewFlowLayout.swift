//
//  MoviesCollectionViewFlowLayout.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import UIKit

final class MoviesCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    public override init() {
        super.init()
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
     
        commonInit()
    }
    
    private func commonInit() {
        scrollDirection = .vertical
        minimumLineSpacing = 30.0
        minimumInteritemSpacing = 30.0
        sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        let screenSize = UIScreen.main.bounds.size
        let itemWidth = screenSize.width - 40.0
        let aspectRatio: CGFloat = 8/10
        let itemHeight = itemWidth / aspectRatio
        itemSize = CGSize(width: itemWidth, height: itemHeight)
    }
}
