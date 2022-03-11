import ObjectMapper
import Foundation

class EventTag: Mappable, ModelDefault {
    
    var id: Int?
    var eventId: Int?
    var tagId: Int?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                           <- map["id"]
        tagId                        <- map["tag_id"]
        eventId                      <- map["event_id"]
    }
}
