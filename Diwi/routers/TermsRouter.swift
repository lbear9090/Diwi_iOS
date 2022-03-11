//
//  TermsRouter.swift
//  Diwi
//
//  Created by Dominique Miller on 1/31/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import Alamofire

enum TermsRouter: URLRequestConvertible {
    case show
    
    private var method: Alamofire.HTTPMethod {
        switch self {
        case .show: return .get
        }
    }
    
    private var path: String {
        switch self {
        case .show: return "/api/v1/terms"
        }
    }
    
    private var params: Parameters? {
        switch self {
        case .show: return nil
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
