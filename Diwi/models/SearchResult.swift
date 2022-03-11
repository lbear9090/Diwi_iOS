//
//  SearchResult.swift
//  Diwi
//
//  Created by Dominique Miller on 4/16/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import ObjectMapper

class SearchResult: Mappable {
    var clothingItems: [ClothingItem]?
    var events: [Event]?
    var looks: [Look]?
    var tags: [Tag]?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        clothingItems             <- map["clothing_items"]
        events                    <- map["events"]
        looks                     <- map["looks"]
        tags                      <- map["tags"]
    }
}
