//
//  UpdateUserService.swift
//  Diwi
//
//  Created by Dominique Miller on 1/9/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift

protocol UpdateUserService {
    func update(with user: User) -> Observable<User>
}
