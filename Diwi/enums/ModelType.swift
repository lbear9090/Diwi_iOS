//
//  ModelType.swift
//  Diwi
//
//  Created by Dominique Miller on 4/9/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
enum ModelType {
    case ClothingItems, Events, Looks, Contacts
}

enum SearchType {
    case Clothing, Event, Look, Contact, Search
}

enum NewLookCellType: Int {
    case title
    case location
    case date
    case notes
}
