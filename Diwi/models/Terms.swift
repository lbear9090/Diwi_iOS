import ObjectMapper
import Foundation

class Terms: Mappable {
    
    var id: Int?
    var consumerId: Int?
    var acceptedAt: String?
    var remoteIp: String?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                       <- map["id"]
        consumerId               <- map["consumer_id"]
        acceptedAt               <- map["accepted_at"]
        remoteIp                 <- map["remote_ip"]
    }
}

