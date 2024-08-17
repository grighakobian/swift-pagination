//
//  MoviesDataSource+UICollectionViewDataSourcePrefetching.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 10.11.21.
//

import UIKit
import SDWebImage

extension MoviesDataSource: UICollectionViewDataSourcePrefetching {
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths
            .map({ sectionItems[$0.item] })
            .map({ $0.movieViewModel?.posterImageUrl })
            .compactMap({ $0 })
        
        SDWebImagePrefetcher.shared.prefetchURLs(urls)
    }
}
