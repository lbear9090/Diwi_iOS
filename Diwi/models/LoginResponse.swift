import Foundation
import ObjectMapper

class LoginResponse: Mappable {
    var jwt: String?
    var user: User?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        jwt                       <- map["jwt"]
        user                      <- map["user"]
    }
}
