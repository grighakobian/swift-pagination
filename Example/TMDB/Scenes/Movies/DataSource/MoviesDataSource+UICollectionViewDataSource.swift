//
//  MoviesDataSource+UICollectionViewDataSource.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 10.11.21.
//

import Foundation
import UIKit

extension MoviesDataSource: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionItem = sectionItems[indexPath.item]
        switch sectionItem {
        case .movie(let movieViewModel):
            let cell = collectionView.dequeueReusableCell(ofType: MovieCollectionViewCell.self, at: indexPath)
            cell.bind(item: movieViewModel)
            return cell
        case .state(let loadingState):
            let cell = collectionView.dequeueReusableCell(ofType: StateCollectionViewCell.self, at: indexPath)
            cell.bind(state: loadingState)
            cell.retryButton.rx.tap
                .bind(to: onRetryButtonTapped)
                .disposed(by: cell.rx.reuseBag)
            return cell
        }
    }
}
