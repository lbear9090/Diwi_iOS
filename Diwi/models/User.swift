import ObjectMapper
import Foundation

class User: Mappable {
    
    var id: Int?
    var email: String?
    var jwt: String?
    var password: String?
    var passwordConfirmation: String?
    var profileType: String?
    var timeZone: String?
    var profile: Profile?
    var device: Device?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                        <- map["id"]
        email                     <- map["email"]
        jwt                       <- map["token"]
        password                  <- map["password"]
        passwordConfirmation      <- map["password_confirmation"]
        profileType               <- map["profile_type"]
        timeZone                  <- map["time_zone"]
        profile                   <- map["profile"]
        device                    <- map["device"]
    }
}
