//
//  TagInfoService.swift
//  Diwi
//
//  Created by Dominique Miller on 11/19/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift

protocol TagInfoService {
    func index() -> Observable<[Tag]>
    func create(tag: Tag) -> Observable<Tag>
    func delete(id: Int) -> Observable<ApiResponseData>
    func show(id: Int) -> Observable<Tag>
    func update(tag: Tag) -> Observable<Tag>
}
