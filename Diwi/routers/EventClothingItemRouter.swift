//
//  EventClothingItem.swift
//  Diwi
//
//  Created by Dominique Miller on 12/3/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import Alamofire

enum EventClothingItemRouter: URLRequestConvertible {
    case create(EventClothingItem), delete(Int)
    
    // MARK: HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .create: return .post
        case .delete: return .delete
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .create:
            return "/api/v1/event_clothing_items"
        case .delete(let id):
            return "/api/v1/event_clothing_items/\(id)"
        }
    }
    
    // MARK: - Parameters
    private var params: Parameters? {
        switch self {
        case .create(let params):
            return params.toJSON()
        case .delete(_):
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        var config = EnvironmentConfiguration()
        
        let url = try config.environment.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        return try! Alamofire.JSONEncoding().encode(urlRequest, with: params)
    }
}
