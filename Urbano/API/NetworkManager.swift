//
//  NetworkManager.swift
//  Urbano
//
//  Created by Mick VE on 13/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

class NetworkManager {
    
    // MARK: - Properties
    
    //static let shared = NetworkManager(environment: Int)
    
    // MARK: - Properties
    
    private static var sharedNetworkManager: NetworkManager = {
        let networkManager = NetworkManager(environment: API.Environment.Production.rawValue)
        
        // Configuration
        if let country = UserDefaultsManager.shared.country {
            networkManager.buildAPI(country: country.rawValue)
        }
        
        return networkManager
    }()
    
    // MARK: -
    
    var scheme = String()
    
    var host = String()
    
    let environment: Int
    
    // Initialization
    
    private init(environment: Int) {
        self.environment = environment
    }
    
    // MARK: - Accessors
    
    class func shared() -> NetworkManager {
        return sharedNetworkManager
    }
    
    func buildURLComponent(scheme: String, host: String, path: String) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        return urlComponents
    }
    
    func getURL(restPath: API.RestPath) -> URLComponents {
        return buildURLComponent(scheme: self.scheme, host: self.host, path: "\(API.BasePath)\(restPath.rawValue)")
    }
    
    func buildAPI(country: Int) {
        switch environment {
        case API.Environment.Production.rawValue:
            self.scheme = API.Scheme.Production
            
            switch country {
            case API.Country.Chile.rawValue:
                self.host = API.Host.Production.Chile
            case API.Country.Ecuador.rawValue:
                self.host = API.Host.Production.Ecuador
            case API.Country.Peru.rawValue:
                self.host = API.Host.Production.Peru
            default:
                self.host = ""
            }
        case API.Environment.Development.rawValue:
            self.scheme = API.Scheme.Development
            
            switch country {
            case API.Country.Chile.rawValue:
                self.host = API.Host.Development.Chile
            case API.Country.Ecuador.rawValue:
                self.host = API.Host.Development.Ecuador
            case API.Country.Peru.rawValue:
                self.host = API.Host.Development.Peru
            default:
                self.host = ""
            }
        default:
            break
        }
    }
    
}
