//
//  Look.swift
//  Diwi
//
//  Created by Dominique Miller on 3/31/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import ObjectMapper
import Foundation

class Look: Mappable {
    var id: Int?
    var image: String?
    var thumbnail: String?
    var title: String?
    var createdAt: Date?
    var datesWorn: [String]?
    var tags: [Tag]?
    var note: String?
    var lookTags: [LookTag]?
    var lookPhotos: [LookPhotos]?
    var events: [Event]?
    var lookEvents: [LookEvent]?
    var lookClothingItems: [LookClothingItem]?
    var clothingItems: [ClothingItem]?
    var clothingItemIds: [Int]?
    var eventIds: [Int]?
    var tagIds: [Int]?
    var lookClothingItemIdsToBeDeleted: [Int]?
    var lookTagIdsToBeDeleted: [Int]?
    var lookEventIdsToBeDeleted: [Int]?
    var datesWornToBeDeleted: [Int]?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                        <- map["id"]
        image                     <- map["image"]
        thumbnail                 <- map["thumbnail"]
        createdAt                 <- (map["created_at"], APIDateTransform())
        title                     <- map["title"]
        datesWorn                 <- map["dates_worn"]
        tags                      <- map["tags"]
        note                      <- map["note"]
        lookTags                  <- map["look_tags"]
        events                    <- map["events"]
        lookEvents                <- map["look_events"]
        lookClothingItems         <- map["look_clothing_items"]
        clothingItems             <- map["clothing_items"]
        clothingItemIds           <- map["clothing_item_ids"]
        eventIds                  <- map["event_ids"]
        tagIds                    <- map["tag_ids"]
        lookClothingItemIdsToBeDeleted <- map["look_clothing_item_ids_to_be_deleted"]
        lookTagIdsToBeDeleted     <- map["look_tag_ids_to_be_deleted"]
        lookEventIdsToBeDeleted   <- map["look_event_ids_to_be_deleted"]
        datesWornToBeDeleted      <- map["dates_worn_to_be_deleted"]
        lookPhotos                <- map["photos"]
    }
    
    func eventDate() -> Date? {
        if let event = events?.last,
            let date = event.date {
            return date
        } else {
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
               lookClothingItemIdsToBeDeleted != nil ||
               lookTagIdsToBeDeleted != nil ||
               lookEventIdsToBeDeleted != nil ||
               datesWornToBeDeleted != nil ||
               datesWorn != nil ||
               tagIds != nil ||
               eventIds != nil ||
               clothingItemIds != nil
    }
}

extension Look: ModelDefault, ClosetItem {}
