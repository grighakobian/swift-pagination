//
//  PopularMoviesViewController+UICollectionViewDelegate.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import UIKit

extension PopularMoviesViewController {
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let nextPageTriggerHeight = scrollView.bounds.height / 2
        
        let contentOffset = scrollView.contentOffset
        let contentHeight = collectionView.contentSize.height
        let viewportHeight = collectionView.frame.height
        
        if contentHeight < viewportHeight {
            nextPageTrigger.onNext(())
        } else {
            let remainingDistance = contentHeight - viewportHeight - nextPageTriggerHeight
            if  remainingDistance < contentOffset.y {
                nextPageTrigger.onNext(())
            }
        }
    }
}
