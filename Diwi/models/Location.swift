//
//  Location.swift
//  Diwi
//
//  Created by Dominique Miller on 11/20/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import ObjectMapper
import Foundation

class Location: Mappable {
    
    var id: Int?
    var address: String?
    var city: String?
    var state: String?
    var postalCode: String?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id                          <- map["id"]
        address                     <- map["street"]
        city                        <- map["city"]
        state                       <- map["state"]
        postalCode                  <- map["postal_code"]
    }
    
    func isNotEmpty() -> Bool {
        return address != nil ||
               city != nil ||
               state != nil ||
               postalCode != nil
    }
}
