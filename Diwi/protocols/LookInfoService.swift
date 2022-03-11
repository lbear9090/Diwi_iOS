//
//  LookInfoService.swift
//  Diwi
//
//  Created by Dominique Miller on 4/8/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift

protocol LookInfoService {
    func index() -> Observable<[Look]>
    func show(id: Int) -> Observable<Look>
    func update(look: Look) -> Observable<Look>
    func create(look: Look) -> Observable<Look>
    func delete(id: Int) -> Observable<ApiResponseData>
}
