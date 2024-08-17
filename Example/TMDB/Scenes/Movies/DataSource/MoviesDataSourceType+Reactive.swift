//
//  MoviesDataSourceType+Reactive.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 10.11.21.
//

import RxSwift


extension Reactive where Base: MoviesDataSourceType {
    
    internal var sectionItems: Binder<[SectionItem]> {
        return Binder(self.base) { dataSource, sectionItems in
            base.setSectionItems(sectionItems)
        }
    }
}
