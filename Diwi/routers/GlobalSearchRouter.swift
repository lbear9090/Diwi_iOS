//
//  GlobalSearchRouter.swift
//  Diwi
//
//  Created by Dominique Miller on 4/16/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import Alamofire

enum GlobalSearchRouter: URLRequestConvertible {
    case search(String)
    
    private var method: Alamofire.HTTPMethod {
        switch self {
        case .search: return .post
        }
    }
    
    private var path: String {
        switch self {
        case .search: return "/api/v1/global_search"
        }
    }
    
    private var params: Parameters? {
        switch self {
        case .search(let param): return ["search_term" : param]
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        var config = EnvironmentConfiguration()
        
        let url = try config.environment.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        return try! Alamofire.JSONEncoding().encode(urlRequest, with: params)
    }
}
