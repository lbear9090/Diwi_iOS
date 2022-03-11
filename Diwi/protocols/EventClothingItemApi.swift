//
//  EventClothingItemApi.swift
//  Diwi
//
//  Created by Dominique Miller on 12/3/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift

protocol EventClothingItemApi {
    func create(eventClothingItem: EventClothingItem) -> Observable<EventClothingItem>
    func delete(id: Int) -> Observable<ApiResponseData>
}
