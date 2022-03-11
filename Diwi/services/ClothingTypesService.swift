//
//  ClothingTypesService.swift
//  Diwi
//
//  Created by Dominique Miller on 9/4/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift

class ClothingTypesService: MainRequestService {
    func index() -> Observable<ClothingTypes> {
        return newRequestWithoutKeyPath(route: ClothingTypesRouter.index)
    }
}
