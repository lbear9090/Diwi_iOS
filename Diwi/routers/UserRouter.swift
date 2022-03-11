import Foundation
import Alamofire

enum UserRouter: URLRequestConvertible {
    case login(User), signup(User), forgotPassword(User), acceptTerms(Terms), update(User)
    
    // MARK: HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .signup:
            return .post
        case .forgotPassword:
            return .post
        case .acceptTerms:
            return .post
        case .update:
            return .patch
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .login:
            return "/api/v1/user_token"
        case .signup:
            return "/api/v1/users"
        case .forgotPassword:
            return "/api/v1/password_reset"
        case .acceptTerms:
            return "/api/v1/terms_acceptances"
        case .update(let params):
            return "/api/v1/users/\(params.id!)"
        }
    }
    
    // MARK: - Parameters
    private var params: Parameters? {
        switch self {
        case .login(let params):
            return [ "auth" : params.toJSON() ]
        case .signup(let params):
            return params.toJSON()
        case .forgotPassword(let params):
            return [ "password_reset" : params.toJSON() ]
        case .acceptTerms(let params):
            return params.toJSON()
        case .update(let params):
            return params.toJSON()
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        var config = EnvironmentConfiguration()
        
        let url = try Constants.Staging.baseURL.asURL()//try config.environment.baseURL.asURL()
//        let url = try config.environment.baseURL.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        return try! Alamofire.JSONEncoding().encode(urlRequest, with: params)
    }
}
