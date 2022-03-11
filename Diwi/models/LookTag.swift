//
//  LookTag.swift
//  Diwi
//
//  Created by Dominique Miller on 3/31/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import ObjectMapper
import Foundation

class LookTag: Mappable, ModelDefault {
    
    var id: Int?
    var lookId: Int?
    var tagId: Int?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                           <- map["id"]
        tagId                        <- map["tag_id"]
        lookId                       <- map["look_id"]
    }
}

