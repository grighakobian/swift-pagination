//
//  AuthenticationPlugin.swift
//  Network
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import Moya
import Foundation


public enum AuthenticationType {
    case noAuth
    case auth(apiKey: String)
}

public protocol Authenticable {
    
    var authenticationType: AuthenticationType { get }
}


public final class AuthenticationPlugin: PluginType {
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let target = target as? Authenticable, let url = request.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return request
        }
        switch target.authenticationType {
        case .noAuth:
            return request
        case .auth(let apiKey):
            var adaptRequst = request
            var queryItems = components.queryItems ?? []
            let queryItem = URLQueryItem(name: "api_key", value: apiKey)
            queryItems.append(queryItem)
            components.queryItems = queryItems
            let url = try! components.asURL()
            adaptRequst.url = url
            return adaptRequst
        }
    }
}
