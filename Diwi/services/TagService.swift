//
//  TagService.swift
//  Diwi
//
//  Created by Dominique Miller on 11/19/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift

class TagService: MainRequestService {
    
    func index() -> Observable<[Tag]> {
        return newRequestWithKeyPathArrayResponse(route: TagRouter.index, keypath: "tags")
    }
    
    func show(id: Int) -> Observable<Tag> {
        return newRequestWithKeyPath(route: TagRouter.show(id), keypath: "tag")
    }
    
    func create(tag: Tag) -> Observable<Tag> {
        return newRequestWithKeyPath(route: TagRouter.create(tag), keypath: "tag")
    }
    
    func delete(id: Int) -> Observable<ApiResponseData>{
        return newRequestWithoutKeyPath(route: TagRouter.delete(id))
    }
    
    func update(tag: Tag) -> Observable<Tag> {
        return newRequestWithKeyPath(route: TagRouter.update(tag), keypath: "tag")
    }
}

extension TagService: TagInfoService {}
