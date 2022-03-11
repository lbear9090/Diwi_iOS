//
//  LookService.swift
//  Diwi
//
//  Created by Dominique Miller on 4/8/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import RxSwift

class LookService: MainRequestService {
    
    func index() -> Observable<[Look]> {
        return newRequestWithKeyPathArrayResponse(route: LookRouter.index, keypath: "looks")
    }
    
    func show(id: Int) -> Observable<Look> {
        return newRequestWithKeyPath(route: LookRouter.show(id), keypath: "look")
    }
    
    func create(look: Look) -> Observable<Look> {
        return newRequestWithKeyPath(route: LookRouter.create(look), keypath: "look")
    }
    
    func update(look: Look) -> Observable<Look> {
        return newRequestWithKeyPath(route: LookRouter.update(look), keypath: "look")
    }
    
    func delete(id: Int) -> Observable<ApiResponseData> {
        return newRequestWithKeyPath(route: LookRouter.delete(id), keypath: "look")
    }
}

extension LookService: LookInfoService {
    
}

