//
//  API.swift
//  Network
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import Foundation
import Moya

private let apiKey = "55b14a25af9de1c89aeecfce2fdf963e"

public enum API: TargetType {
    
    case popularMovies(page: Int)
    case similarMovies(id: Int, page: Int)
    
    public var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }
    
    public var path: String {
        switch self {
        case .popularMovies:
            return "tv/popular"
        case .similarMovies(let id, _):
            return "tv/\(id)/similar"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Task {
        switch self {
        case .popularMovies(let page):
            let parameters = ["page": page]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .similarMovies(_, let page):
            let parameters = ["page": page]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
}


// MARK: - Authenticable

extension API: Authenticable {
    
    public var authenticationType: AuthenticationType {
        switch self {
        case .popularMovies,
             .similarMovies:
            return .auth(apiKey: apiKey)
        }
    }
}

