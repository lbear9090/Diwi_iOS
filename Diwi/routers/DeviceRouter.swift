import Foundation
import Alamofire

enum DeviceRouter: URLRequestConvertible {
    case create(Device), update(Device)
    
    private var method: Alamofire.HTTPMethod {
        switch self {
        case .create:
            return .post
        case .update:
            return .patch
        }
    }
    
    private var path: String {
        switch self {
        case .create:
            return "/api/devices"
        case .update(let device):
            return "/api/devices/\(device.id!)"
        }
    }
    
    private var params: Parameters? {
        switch self {
        case .create(let params):
            return [ "device" : params.toJSON() ]
        case .update(let params):
            return [ "device" : params.toJSON() ]
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
