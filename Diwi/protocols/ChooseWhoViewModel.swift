//
//  ChooseWhoViewModal.swift
//  Diwi
//
//  Created by Dominique Miller on 4/9/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol ChooseWhoViewModel {
    func updateTagsArray(newName: String) -> Void
    var tags: BehaviorRelay<[Tag]> { get }
}
