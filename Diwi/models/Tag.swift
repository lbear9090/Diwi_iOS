import ObjectMapper
import Foundation

class Tag: Mappable, ModelDefault {
    
    var id: Int?
    var title: String?
    var createdAt: Date?
    var images: [String]?
    var note: String?
    var selected = false
    var clothingItems: [ClothingItem]?
    var clothingItemTags: [ClothingItemTag]?
    var events: [Event]?
    var eventTags: [EventTag]?
    var looks: [Look]?
    var lookTags: [LookTag]?
    var datesWith: [String]?
    var tagClothingItemIdsToBeDeleted: [Int]?
    var tagLookIdsToBeDeleted: [Int]?
    var tagEventIdsToBeDeleted: [Int]?
    var datesWithToBeDeleted: [String]?
    var lookIds: [Int]?
    var eventIds: [Int]?
    var clothingItemIds: [Int]?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                           <- map["id"]
        title                        <- map["title"]
        createdAt                    <- (map["created_at"], APIDateTransform())
        images                       <- map["images"]
        note                         <- map["note"]
        clothingItems                <- map["clothing_items"]
        events                       <- map["events"]
        eventTags                    <- map["event_tags"]
        clothingItemTags             <- map["clothing_item_tags"]
        looks                        <- map["looks"]
        lookTags                     <- map["look_tags"]
        datesWith                    <- map["dates_with"]
        tagClothingItemIdsToBeDeleted <- map["tag_clothing_item_ids_to_be_deleted"]
        tagLookIdsToBeDeleted        <- map["tag_look_ids_to_be_deleted"]
        tagEventIdsToBeDeleted       <- map["tag_event_ids_to_be_deleted"]
        datesWithToBeDeleted         <- map["dates_with_to_be_deleted"]
        lookIds                      <- map["look_ids"]
        eventIds                     <- map["event_ids"]
        clothingItemIds              <- map["clothing_item_ids"]
    }
    
    func hasImages() -> Bool {
        if let images = self.images, images.count > 0 {
            return true
        } else {
            return false
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
               tagClothingItemIdsToBeDeleted != nil ||
               tagLookIdsToBeDeleted != nil ||
               tagEventIdsToBeDeleted != nil ||
               datesWithToBeDeleted != nil ||
               datesWith != nil ||
               lookIds != nil ||
               eventIds != nil ||
               clothingItemIds != nil
    }
}
