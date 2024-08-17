//
//  Observable.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import RxSwift
import RxCocoa

extension ObservableType {
   
    func catchErrorJustComplete() -> Observable<Element> {
        return `catch` { _ in
            return Observable.empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
    
    func mapVoid() -> Observable<()> {
        return map { _ in return }
    }
}
