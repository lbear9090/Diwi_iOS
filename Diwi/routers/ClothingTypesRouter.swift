import Foundation
import Alamofire

enum ClothingTypesRouter: URLRequestConvertible {
    case index
    
    // MARK: HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .index:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .index: return "/api/v1/clothing_types"
        }
    }
    
    // MARK: - Parameters
    private var params: Parameters? {
        switch self {
        case .index: return nil
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
