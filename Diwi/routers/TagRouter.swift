//
//  TagRouter.swift
//  Diwi
//
//  Created by Dominique Miller on 11/19/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//
import Foundation
import Alamofire

enum TagRouter: URLRequestConvertible {
    case index,
         create(Tag),
         delete(Int),
         show(Int),
         update(Tag)
    
    // MARK: HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .index:
            return .get
        case .show:
            return .get
        case .create:
            return .post
        case .delete:
            return .delete
        case .update:
            return .patch
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .index:
            return "/api/v1/tags"
        case .show(let id):
            return "/api/v1/tags/\(id)"
        case .create:
            return "/api/v1/tags"
        case .delete(let id):
            return "/api/v1/tags/\(id)"
        case .update(let params):
            return "/api/v1/tags/\(params.id!)"
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
            return [ "title": params.title!]
        case .delete:
            return nil
        case .update(let params):
            return params.toJSON()
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

