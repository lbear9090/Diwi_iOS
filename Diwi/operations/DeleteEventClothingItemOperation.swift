//
//  DeleteEventClothingItemOperation.swift
//  Diwi
//
//  Created by Dominique Miller on 12/3/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift

class DeleteEventClothingItemOperation: AsyncOperation {
    
    private let eventClothingItemService = EventClothingItemService()
    private let disposebag   = DisposeBag()
    private let id: Int
    
    init(id: Int) {
       self.id = id
    }
    
    override func main() {
        guard isCancelled == false else {
            self.state = .finished
            return
        }
        
        deleteEventItem()
    }
    
    func deleteEventItem() {
        eventClothingItemService
            .delete(id: id)
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

