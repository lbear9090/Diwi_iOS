import Foundation
import Alamofire

enum EventRouter: URLRequestConvertible {
    case index,
         tags,
         search([Int]),
         create(Event),
         show(Int),
         delete(Int),
         edit(Event)
    
    // MARK: HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .index:
            return .get
        case .tags:
            return .get
        case .search:
            return .post
        case .create:
            return .post
        case .show:
            return .get
        case .delete:
            return  .delete
        case .edit:
            return .patch
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .index:
            return "/api/v1/events"
        case .tags:
            return "/api/v1/tags"
        case .search:
            return "/api/v1/events/search"
        case .create:
            return "/api/v1/events"
        case .show(let id):
            return "/api/v1/events/\(id)"
        case .delete(let id):
            return "/api/v1/events/\(id)"
        case .edit(let event):
            return "/api/v1/events/\(event.id!)"
        }
    }
    
    // MARK: - Parameters
    private var params: Parameters? {
        switch self {
        case .index:
            return nil
        case .tags:
            return nil
        case .search(let params):
            return [ "tag_ids": params ]
        case .create(let params):
            return params.toJSON()
        case .show:
            return nil
        case .delete:
            return nil
        case .edit(let params):
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
