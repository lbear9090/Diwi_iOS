//
//  LookClothingItemTag.swift
//  Diwi
//
//  Created by Dominique Miller on 4/7/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import ObjectMapper
import Foundation

class LookClothingItem: Mappable, ModelDefault {
    
    var id: Int?
    var clothingItemId: Int?
    var lookId: Int?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                           <- map["id"]
        lookId                       <- map["look_id"]
        clothingItemId               <- map["clothing_item_id"]
    }
}
