//
//  EventViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 12/5/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct EventViewModel {
    var eventDateMonth: Driver<String> { return _eventDateMonth.asDriver() }
    var eventDateDay: Driver<String> { return _eventDateDay.asDriver() }
    var eventName: Driver<String> { return _eventName.asDriver() }
    var eventTime: Driver<String> { return _eventTime.asDriver() }
    var eventAddressOne: Driver<String> { return  _eventAddressOne.asDriver() }
    var eventAddressTwo: Driver<String> { return _eventAddressTwo.asDriver() }
    var eventTags: Driver<String> { return _eventTags.asDriver() }
    var eventClothingItems: Driver<[EventClothingItem]> { return _eventClothingItems.asDriver() }
    var success: Driver<Bool> { return _sucess.asDriver() }
    var isLoading: Driver<Bool> { return _isLoading.asDriver() }
    var errorMessage: Driver<String> { return _errorMessage.asDriver() }
    
    let event                       = BehaviorRelay<Event>(value: Event())
    private let _eventName          = BehaviorRelay<String>(value: "")
    private let _eventTime          = BehaviorRelay<String>(value: "")
    private let _eventAddressOne    = BehaviorRelay<String>(value: "")
    private let _eventAddressTwo    = BehaviorRelay<String>(value: "")
    private let _eventTags          = BehaviorRelay<String>(value: "")
    private let _eventDateMonth     = BehaviorRelay<String>(value: "")
    private let _eventDateDay       = BehaviorRelay<String>(value: "")
    private let _eventClothingItems = BehaviorRelay<[EventClothingItem]>(value: [])
    private let _sucess             = BehaviorRelay<Bool>(value: false)
    private let _errorMessage       = BehaviorRelay<String>(value: "")
    private let _isLoading          = BehaviorRelay<Bool>(value: false)
    private let disposebag          = DisposeBag()
    
    private let eventService: EventInfoService
    
    init(event: Event, eventService: EventInfoService) {
        self.eventService = eventService
        
        guard let id = event.id else { return }
        getEvent(with: id)
    }
    
    private func getEvent(with id: Int) {
        _isLoading.accept(true)
        eventService.show(id: id)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { event in
                self.setup(event: event)
                self._isLoading.accept(false)
            }, onError: { error in
                self._isLoading.accept(false)
                if error is ErrorResponseObject {
                    self._errorMessage.accept(TextContent.Errors.couldNotRetrieveEvent)
                }
            }).disposed(by: disposebag)
    }
    
    private func setup(event: Event) {
        self.event.accept(event)
        
        if let date = event.date {
            _eventDateMonth.accept(date.toString("MMM").uppercased())
            _eventDateDay.accept(date.toString("dd"))
        }
        
        if let name = event.name {
            _eventName.accept(name)
        }
        
        if let tags = event.tags {
            let tagsString = buildTagString(tags: tags)
            _eventTags.accept(tagsString)
        }
        
        if let time = event.timeOfDay() {
            _eventTime.accept(time)
        }
        
        if let items = event.eventClothingItems {
            _eventClothingItems.accept(items)
        }
        
        guard let location = event.location else { return }
        
        if let addressOne = location.address {
            let address = "\(addressOne),"
            _eventAddressOne.accept(address)
        }
        
        if let city = location.city,
            let state = location.state,
            let zip = location.postalCode {
            let addressTwo = "\(city), \(state) \(zip)"
            _eventAddressTwo.accept(addressTwo)
        }
    }
    
    private func buildTagString(tags: [Tag]) -> String {
        // Ok to force unwrap optional as API validates presence of title
        let strings: [String] = tags.map { $0.title! }
        let string = strings.joined(separator: ", ")
        return string
    }
    
    func clothingItem(at index: Int) -> ClothingItem {
        let eventItem = _eventClothingItems.value[index]
        
        return convertEventClothingItemToClothingItem(for: eventItem)
    }
    
    private func convertEventClothingItemToClothingItem(for eventItem: EventClothingItem) -> ClothingItem {
        let clothingItem       = ClothingItem()
        clothingItem.id        = eventItem.clothingItemId
        
        return clothingItem
    }
}
