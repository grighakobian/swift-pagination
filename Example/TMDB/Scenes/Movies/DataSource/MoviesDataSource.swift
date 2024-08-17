//
//  MoviesDataSource.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 09.11.21.
//

import Foundation
import UIKit
import RxSwift
import DifferenceKit

protocol MoviesDataSourceType: AnyObject {
    var sectionItems: [SectionItem] { get }
    func setSectionItems(_ newSectionItems: [SectionItem])
    
    /// Triggers when user taps on retry button in the cell
    var onRetryButtonTapped: PublishSubject<Void> { get }
}

public class MoviesDataSource: NSObject, MoviesDataSourceType  {
    
    private(set) var sectionItems: [SectionItem]
    private(set) weak var collectionView: UICollectionView!
    private(set) var onRetryButtonTapped: PublishSubject<Void>
    
    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.sectionItems = [SectionItem]()
        self.onRetryButtonTapped = PublishSubject<Void>()
        super.init()
        
        self.collectionView.dataSource = self
        self.collectionView.prefetchDataSource = self
        self.collectionView.register(MovieCollectionViewCell.self)
        self.collectionView.register(StateCollectionViewCell.self)
    }
    
    func setSectionItems(_ newSectionItems: [SectionItem]) {
        let changeset = StagedChangeset(source: sectionItems, target: newSectionItems)
        collectionView.reload(using: changeset) { newSectionItems in
            self.sectionItems = newSectionItems
        }
    }
}
