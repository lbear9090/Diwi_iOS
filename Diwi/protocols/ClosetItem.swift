//
//  ImageIndexItem.swift
//  Diwi
//
//  Created by Dominique Miller on 4/8/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation

protocol ClosetItem {
    var id: Int? { get set }
    var createdAt: Date? { get }
    var title: String? { get set }
    var image: String? { get set }
    var thumbnail: String? { get set }
    func eventDate() -> Date?
}
