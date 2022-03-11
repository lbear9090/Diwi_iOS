import Alamofire

class APIClient {
    static let session = APIClient.createSession()
    
    static func createSession() -> Alamofire.SessionManager {
        let session = Alamofire.SessionManager()
        session.adapter = AuthAdapter()
        return session
    }
}
