//
//  ViewModel.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import class RxSwift.DisposeBag

/// The view model protocol
public protocol ViewModel {
    
    /// The view model Input
    associatedtype Input
    
    /// The view model Output
    associatedtype Output
    
    /// Transfors view model input into bindable output
    /// - Parameters:
    ///   - input: The view model input
    ///   - disposeBag: The dispose bag to dispose subscriptions
    func transform(input: Input, disposeBag: DisposeBag)-> Output
}
