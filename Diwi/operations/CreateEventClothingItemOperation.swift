//
//  CreateEventClothingItemOperation.swift
//  Diwi
//
//  Created by Dominique Miller on 12/3/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift

class CreateEventClothingItemOperation: AsyncOperation {
    
    private let eventClothingItemService = EventClothingItemService()
    private let disposebag   = DisposeBag()
    private let eventClothingItem: EventClothingItem
    
    init(eventClothingItem: EventClothingItem) {
        self.eventClothingItem = eventClothingItem
    }
    
    override func main() {
        guard isCancelled == false else {
            self.state = .finished
            return
        }
        
        createEventItem()
    }
    
    func createEventItem() {
        eventClothingItemService
            .create(eventClothingItem: eventClothingItem)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                // operation finished
                self.state = .finished
            }, onError: { error in
                // operation finished
                self.state = .finished
            }).disposed(by: disposebag)
    }
}


