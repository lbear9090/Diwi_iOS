//
//  EditOrAddViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 1/16/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol EditEventOrAddEventViewModel {
    var time: BehaviorRelay<String> { get }
    var address: BehaviorRelay<String> { get }
    var city: BehaviorRelay<String> { get }
    var zip: BehaviorRelay<String> { get }
    var state: BehaviorRelay<String> { get }
    var tags: BehaviorRelay<[Tag]> { get }
    func setAddress() -> Void
    func updateTagsArray(newName: String) -> Void
    func validateAddressFields() -> Bool
}
