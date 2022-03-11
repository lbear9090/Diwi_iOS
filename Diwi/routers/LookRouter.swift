//
//  LookRouter.swift
//  Diwi
//
//  Created by Dominique Miller on 4/8/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import Alamofire

enum LookRouter: URLRequestConvertible {
    case index, show(Int), create(Look), update(Look), delete(Int)
    
    // MARK: HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .index: return .get
        case .show: return .get
        case .create: return .post
        case .update: return .patch
        case .delete: return .delete
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .index:
            return "/api/v1/looks"
        case .show(let id):
            return "/api/v1/looks/\(id)"
        case .create:
            return "/api/v1/looks"
        case .update(let params):
            return "/api/v1/looks/\(params.id!)"
        case .delete(let id):
            return "/api/v1/looks/\(id)"
        }
    }
    
    // MARK: - Parameters
    private var params: Parameters? {
        switch self {
        case .index:
            return nil
        case .show:
            return nil
        case .create(let params):
            return params.toJSON()
        case .update(let params):
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
