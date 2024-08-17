//
//  NetworkProvider.swift
//  Network
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import Foundation
import Moya

public protocol NetworkProviderType: AnyObject {
    init(configuration: URLSessionConfiguration)
    
    func provideDefaultNetworkProvider()->MoyaProvider<API>
}

public final class NetworkProvider: NetworkProviderType {
    
    private let moyaProvider: MoyaProvider<API>
    
    public init(configuration: URLSessionConfiguration) {
        let session = Session(configuration: configuration)
        let configuration = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        let networkLoggerPlugin = NetworkLoggerPlugin(configuration: configuration)
        let authenticationPlugin = AuthenticationPlugin()
        let plugins: [PluginType] = [networkLoggerPlugin, authenticationPlugin]
        moyaProvider = MoyaProvider<API>(session: session, plugins: plugins)
    }
    
    public func provideDefaultNetworkProvider() -> MoyaProvider<API> {
        return moyaProvider
    }
}
