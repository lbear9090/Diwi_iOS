//
//  LookEvent.swift
//  Diwi
//
//  Created by Dominique Miller on 4/7/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import ObjectMapper
import Foundation

class LookEvent: Mappable, ModelDefault {
    
    var id: Int?
    var lookId: Int?
    var eventId: Int?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                           <- map["id"]
        eventId                      <- map["event_id"]
        lookId                       <- map["look_id"]
    }
}
