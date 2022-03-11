import Foundation
import Alamofire

enum ClothingItemRouter: URLRequestConvertible {
    case index, show(Int), create(ClothingItem), update(ClothingItem), delete(Int)
    
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
            return "/api/v1/clothing_items"
        case .show(let id):
            return "/api/v1/clothing_items/\(id)"
        case .create:
            return "/api/v1/clothing_items"
        case .update(let params):
            return "/api/v1/clothing_items/\(params.id!)"
        case .delete(let id):
            return "/api/v1/clothing_items/\(id)"
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
