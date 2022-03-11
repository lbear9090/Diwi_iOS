import ObjectMapper
import Foundation

class ErrorType: Mappable, Codable {
    var email: [String]?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        email    <- map["email"]
    }
}

class ApiResponseData: Mappable, Codable {
    var errors: ErrorType?
    var message: String?
    var terms: String?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
       errors         <- map["errors"]
       message        <- map["message"]
       terms          <- map["terms"]
    }
}
