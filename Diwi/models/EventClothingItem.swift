import ObjectMapper
import Foundation

class EventClothingItem: Mappable, Equatable, ModelDefault {
    
    static func == (lhs: EventClothingItem, rhs: EventClothingItem) -> Bool {
        return lhs.eventId == rhs.eventId  && lhs.title == rhs.title && lhs.date == rhs.date
    }
    
    
    
    var id: Int?
    var date: Date?
    var eventId: Int?
    var clothingItemId: Int?
    var title: String?
    var image: String?
    var thumbnail: String?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                           <- map["id"]
        image                        <- map["image"]
        eventId                      <- map["event_id"]
        clothingItemId               <- map["clothing_item_id"]
        title                         <- map["name"]
        date                         <- (map["date"], APIDateTransform())
        thumbnail                    <- map["thumbnail"]
    }
    
    func calendarDate() -> String? {
        let df = DateFormatter()
        df.dateFormat = "M-d-yy"
        if let d = date {
            return df.string(from: d)
        }
        return nil
    }
    
    func timeOfDay() -> String? {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        if let d = date {
            return df.string(from: d)
        }
        return nil
    }
}
