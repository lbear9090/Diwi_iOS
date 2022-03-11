import ObjectMapper
import Foundation

class Event: Mappable, ModelDefault, Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id  && lhs.date == rhs.date && lhs.name == rhs.name
    }
    
    var id: Int?
    var date: Date?
    var createdAt: Date?
    var name: String?
    var image: String?
    var note: String?
    var tagIds: [Int]?
    var lookIds: [Int]?
    var clothingItemIds: [Int]?
    var location: Location?
    var tags: [Tag]?
    var looks: [Look]?
    var clothingItems: [ClothingItem]?
    var eventTagIdsToBeDeleted: [Int]?
    var eventClothingItemIdsToBeDeleted: [Int]?
    var lookEventIdsToBeDeleted: [Int]?
    var eventTags: [EventTag]?
    var eventClothingItems: [EventClothingItem]?
    var lookEvents: [LookEvent]?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                           <- map["id"]
        image                        <- map["image"]
        name                         <- map["name"]
        date                         <- (map["date"], APIDateTransform())
        createdAt                    <- (map["created_at"], APIDateTransform())
        tagIds                       <- map["tag_ids"]
        clothingItemIds              <- map["clothing_item_ids"]
        location                     <- map["location"]
        tags                         <- map["tags"]
        looks                        <- map["looks"]
        clothingItems                <- map["clothing_items"]
        lookIds                      <- map["look_ids"]
        clothingItemIds              <- map["clothing_item_ids"]
        note                         <- map["note"]
        eventClothingItems           <- map["event_clothing_items"]
        eventTags                    <- map["event_tags"]
        lookEvents                   <- map["look_events"]
        eventTagIdsToBeDeleted       <- map["event_tag_ids_to_be_deleted"]
        eventClothingItemIdsToBeDeleted <- map["event_clothing_item_ids_to_be_deleted"]
        lookEventIdsToBeDeleted      <- map["look_event_ids_to_be_deleted"]
     }
    
    func datePretty() -> String? {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMM d, yyyy"
        if let d = date {
            return df.string(from: d)
        }
        return nil
    
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
    
    func isNotEmpty() -> Bool {
        return note != nil ||
               name != nil ||
               date != nil ||
               location != nil ||
               eventTagIdsToBeDeleted != nil ||
               eventClothingItemIdsToBeDeleted != nil ||
               eventClothingItemIdsToBeDeleted != nil ||
               lookEventIdsToBeDeleted != nil ||
               clothingItemIds != nil ||
               tagIds != nil ||
               lookIds != nil
    }
}
