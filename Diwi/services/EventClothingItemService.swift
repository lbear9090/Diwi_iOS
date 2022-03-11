//
//  EventClothingItem.swift
//  Diwi
//
//  Created by Dominique Miller on 12/3/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class EventClothingItemService: MainRequestService {
    func create(eventClothingItem: EventClothingItem) -> Observable<EventClothingItem> {
        return newRequestWithKeyPath(route: EventClothingItemRouter.create(eventClothingItem), keypath: "event_clothing_item")
    }
    
    func delete(id: Int) -> Observable<ApiResponseData> {
        return newRequestWithKeyPath(route: EventClothingItemRouter.delete(id), keypath: "event_clothing_item")
    }
}

extension EventClothingItemService: EventClothingItemApi {
}
