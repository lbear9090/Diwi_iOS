import ObjectMapper
import Foundation

class ClothingItem: Mappable {
    
    var id: Int?
    var image: String?
    var thumbnail: String?
    var lastEventDate: String?
    var title: String?
    var typeOf: String?
    var createdAt: Date?
    var eventClothingItems: [EventClothingItem]?
    var note: String?
    var datesWorn: [String]?
    var clothingItemTags: [ClothingItemTag]?
    var lookClothingItems: [LookClothingItem]?
    var tags: [Tag]?
    var events: [Event]?
    var looks: [Look]?
    var tagIds: [Int]?
    var eventIds: [Int]?
    var lookIds: [Int]?
    var datesWornToBeDeleted: [String]?
    var clothingItemTagsToBeDeleted: [Int]?
    var eventClothingItemsToBeDeleted: [Int]?
    var lookClothingItemsToBeDeleted: [Int]?
    
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                          <- map["id"]
        image                       <- map["image"]
        thumbnail                   <- map["thumbnail"]
        lastEventDate               <- map["last_event_date"]
        title                       <- map["name"]
        typeOf                      <- map["type_of"]
        createdAt                   <- (map["created_at"], APIDateTransform())
        eventClothingItems          <- map["event_clothing_items"]
        note                        <- map["note"]
        datesWorn                   <- map["dates_worn"]
        clothingItemTags            <- map["clothing_item_tags"]
        lookClothingItems           <- map["look_clothing_items"]
        tags                        <- map["tags"]
        events                      <- map["events"]
        looks                       <- map["looks"]
        tagIds                      <- map["tag_ids"]
        eventIds                    <- map["event_ids"]
        lookIds                     <- map["look_ids"]
        datesWornToBeDeleted        <- map["dates_worn_to_be_deleted"]
        clothingItemTagsToBeDeleted <- map["clothing_item_tags_to_be_deleted"]
        eventClothingItemsToBeDeleted <- map["event_clothing_items_to_be_deleted"]
        lookClothingItemsToBeDeleted <- map["look_clothing_items_to_be_deleted"]
    }
    
    func eventDate() -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
        if let lastEventDate = lastEventDate {
            return df.date(from: lastEventDate)
        }
        else {
            return nil
        }
    }
    
    func createdAtPretty() -> String? {
        let df = DateFormatter()
        df.dateFormat = "MMM d yyyy  hh:mm:ss"
        if let date = createdAt {
            return df.string(from: date)
        }
        return nil
    }
    
    func isNotEmpty() -> Bool {
        return title != nil ||
               note != nil ||
               typeOf != nil ||
               eventClothingItemsToBeDeleted != nil ||
               clothingItemTagsToBeDeleted != nil ||
               lookClothingItemsToBeDeleted != nil ||
               datesWornToBeDeleted != nil ||
               datesWorn != nil ||
               tagIds != nil ||
               eventIds != nil ||
               lookIds != nil
    }
}

extension ClothingItem: ModelDefault, ClosetItem {}
