import ObjectMapper
import Foundation

class Profile: Mappable {
    
    var id: Int?
    var firstName: String?
    var lastName: String?
    var userName: String?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                        <- map["id"]
        lastName                  <- map["last_name"]
        firstName                 <- map["first_name"]
        userName                  <- map["username"]
    }
}

class LookPhotos: Mappable, ModelDefault {
    
    var id: Int?
    var image: String?
    var thumbnail: String?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                           <- map["id"]
        image                        <- map["image"]
        thumbnail                    <- map["thumbnail"]
    }
}


