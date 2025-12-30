//
//  URLBuilder.swift
//  MyPT
//
//  Created by techsaga corp on 27/01/25.
//

import Foundation

class URLBuilder {
    private var components = URLComponents()
    let baseScheme = AppBaseUrl.baseScheme.rawValue
    let baseURL = isTesting ? AppBaseUrl.baseProductionUrl.rawValue : AppBaseUrl.baseDevUrl.rawValue
    
//    let baseURL = AppBaseUrl.baseDevUrl.rawValue
//    let port = 8874
    
    init() {
        self.components.scheme = baseScheme
        self.components.host = baseURL
//        self.components.port = port
    }
    
    func set(port: Int) -> URLBuilder {
        self.components.port = port
        return self
    }
    
    func set(path: String) -> URLBuilder {
        var path = path
        if !path.hasPrefix("/") {
            path = "/" + path
        }
        self.components.path = path
        return self
    }
    
    func addQueryItem(queries: [String: String]?) -> URLBuilder  {
        guard let queries = queries else{return self}
        if self.components.queryItems == nil {
            self.components.queryItems = []
        }
        let qs = queries.map({URLQueryItem(name: $0.key, value: $0.value)})
        self.components.queryItems?.append(contentsOf: qs)
        return self
    }
    
    func build() -> URL? {
        self.components.url
    }
}
