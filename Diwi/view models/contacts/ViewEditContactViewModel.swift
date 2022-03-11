//
//  ViewEditContactViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 3/31/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

class ViewEditContactViewModel {
    let dateAdded                  = BehaviorRelay<String>(value: "")
    let name                       = BehaviorRelay<String>(value: "")
    let note                       = BehaviorRelay<String>(value: "")
    let closetItems                = BehaviorRelay<[ClosetItem]>(value: [])
    let clothingItems              = BehaviorRelay<[ClothingItem]>(value: [])
    let looks                      = BehaviorRelay<[Look]>(value: [])
    let events                     = BehaviorRelay<[Event]>(value: [])
    let datesWith                  = BehaviorRelay<[String]>(value: [])
    let isLoading                  = BehaviorRelay<Bool>(value: false)
    let formIsValid                = BehaviorRelay<Bool>(value: false)
    let success                    = BehaviorRelay<Bool>(value: false)
    let errorStatus                = BehaviorRelay<Int>(value: 0)
    let errorMsg                   = BehaviorRelay<String>(value: "")
    let viewMode                   = BehaviorRelay<ViewingMode>(value: .view)
    private let clothingItemTags   = BehaviorRelay<[ClothingItemTag]>(value: [])
    private let eventTags          = BehaviorRelay<[EventTag]>(value: [])
    private let lookTags           = BehaviorRelay<[LookTag]>(value: [])
    private let contact            = BehaviorRelay<Tag>(value: Tag())
    
    private var tagService: TagInfoService
    private let dateFormatter = DateFormatter()
    let disposeBag = DisposeBag()
    
    private var tagClothingItemIdsToBeDeleted: [Int] = []
    private var tagLookIdsToBeDeleted: [Int] = []
    private var tagEventIdsToBeDeleted: [Int] = []
    private var datesWithToBeDeleted: [String] = []
    
    private var clothingItemIdsToAdd: [Int] = []
    private var lookIdsToAdd: [Int] = []
    private var eventIdsToAdd: [Int] = []
    private var datesWithToAdd: [String] = []
    
    
    init(id: Int, tagService: TagInfoService) {
        self.tagService = tagService
        getContactInfo(with: id)
    }
    
    func resetView() {
        updateViewingMode(to: .view)
        setup(for: contact.value)
    }
    
    private func setup(for contact: Tag) {
        if let name = contact.title {
            self.name.accept(name)
        }
        
        if let note = contact.note {
            self.note.accept(note)
        }
        
        if let clothingItems = contact.clothingItems {
            self.clothingItems.accept(clothingItems)
        }
        
        if let clothingItemTags = contact.clothingItemTags {
            self.clothingItemTags.accept(clothingItemTags)
        }
        
        if let looks = contact.looks {
            self.looks.accept(looks)
        }
        
        if let events = contact.events {
            self.events.accept(events)
        }
        
        if let eventTags = contact.eventTags {
            self.eventTags.accept(eventTags)
        }
        
        if let date = contact.createdAtPretty() {
            dateAdded.accept(date)
        }

        if let dates = contact.datesWith {
            datesWith.accept(dates)
        }
        
        updateClosetItems()
    }
}

// MARK: - Convienance methods
extension ViewEditContactViewModel {
    func closetItemsCount() -> Int {
        return closetItems.value.count
    }
    
    func clothingItemsCount() -> Int {
        return clothingItems.value.count
    }
    
    func eventsCount() -> Int {
        return events.value.count
    }
    
    func looksCount() -> Int {
        return looks.value.count
    }
    
    func datesCount() -> Int {
        return datesWith.value.count
    }
    
    func getClosetItem(at index: Int) -> ClosetItem {
        return closetItems.value[index]
    }
    
    func getClothingItem(at index: Int) -> ClothingItem {
        return clothingItems.value[index]
    }
    
    func getAllItemsFor(_ model: ModelType) -> [ModelDefault] {
        switch model {
        case .ClothingItems:
            return clothingItems.value
        case .Events:
            return events.value
        case .Looks:
            return looks.value
        default:
            return []
        }
    }
    
    func getAllDatesWith() -> [String] {
        return datesWith.value
    }
    
    func getEvent(at index: Int) -> Event {
        return events.value[index]
    }
    
    func getLook(at index: Int) -> Look {
        return looks.value[index]
    }
    
    func getDate(at index: Int) -> String {
        return datesWith.value[index]
    }
    
    func updateViewingMode(to mode: ViewingMode) {
        viewMode.accept(mode)
    }
    
    private func updateClosetItems() {
        let items = clothingItems.value
        let looks = self.looks.value
        var closetItems: [ClosetItem] = []
        closetItems.append(contentsOf: items)
        closetItems.append(contentsOf: looks)
        
        self.closetItems.accept(closetItems)
    }
    
    func updateClothingItems(with items: [ClothingItem]) {
        clothingItems.accept(items)
        for item in items {
            addItem(item: item,
                    itemsToMatchAgainst: clothingItemTags.value,
                    appendTo: &clothingItemIdsToAdd)
        }
        
        updateClosetItems()
    }
    
    func updateLooks(with looks: [Look]) {
        self.looks.accept(looks)
        for look in looks {
            addItem(item: look,
                    itemsToMatchAgainst: lookTags.value,
                    appendTo: &lookIdsToAdd)
        }
        
        updateClosetItems()
    }
    
    func updateEvents(with events: [Event]) {
        self.events.accept(events)
        
        for event in events {
            addItem(item: event,
                    itemsToMatchAgainst: eventTags.value,
                    appendTo: &eventIdsToAdd)
        }
    }
    
    private func formatDateForDateWithString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func updateDatesWith(with date: Date) {
        let dateString = formatDateForDateWithString(date: date)
        var existingItems = datesWith.value
        // check if dateString already exists
        if  !existingItems.contains(where: {$0 == dateString}) {
            existingItems.append(dateString)
            datesWithToAdd.append(dateString)
            datesWith.accept(existingItems)
        }
    }
}

// MARK: - Managing arrays
extension ViewEditContactViewModel {
    
    func removeClosetItem(item: ClosetItem) {
        if let item = item as? ClothingItem {
            removeClothingItem(item: item)
        }
        
        if let look = item as? Look {
            removeLook(look: look)
        }
        
        updateClosetItems()
    }
    
    private func removeClothingItem(item: ClothingItem) {
        var items = clothingItems.value
        if let id = item.id,
            let index = items.firstIndex(where: { $0.id == id}) {
            items.remove(at: index)
            addToTagClothingItemsToBeDeleted(with: id)
            clothingItems.accept(items)
            removeFromAddedArray(with: id, arrayToCheck: &clothingItemIdsToAdd)
        }
    }
    
    private func removeLook(look: Look) {
        var looks = self.looks.value
        if let id = look.id,
            let index = looks.firstIndex(where: { $0.id == id}) {
            looks.remove(at: index)
            addToLookTagsToBeDeleted(with: id)
            self.looks.accept(looks)
            removeFromAddedArray(with: id, arrayToCheck: &lookIdsToAdd)
        }
    }
    
    private func removeFromAddedArray(with id: Int, arrayToCheck: inout [Int]) {
        if let index = arrayToCheck.firstIndex(where: { $0 == id }) {
            arrayToCheck.remove(at: index)
        }
    }
    
    private func addToLookTagsToBeDeleted(with lookId: Int) {
        if let item = lookTags.value.first(where: { $0.lookId == lookId }),
            let id = item.id {
            tagLookIdsToBeDeleted.append(id)
        }
    }
    
    private func addToTagClothingItemsToBeDeleted(with clothingId: Int) {
        if let item = clothingItemTags.value.first(where: { $0.clothingItemId == clothingId }),
            let id = item.id {
            tagClothingItemIdsToBeDeleted.append(id)
        }
    }
    
    func removeEvent(item: Event) {
        var items = events.value
        if let id = item.id,
            let index = items.firstIndex(where: { $0.id == id}) {
            items.remove(at: index)
            addToTagEventItemsToBeDeleted(with: id)
            events.accept(items)
            removeFromAddedArray(with: id, arrayToCheck: &eventIdsToAdd)
        }
    }
    
    private func addToTagEventItemsToBeDeleted(with eventId: Int) {
        if let item = eventTags.value.first(where: { $0.eventId == eventId }),
            let id = item.id {
            tagEventIdsToBeDeleted.append(id)
        }
    }
    
    func removeFromDateWith(date: String) {
        var items = datesWith.value
        if let index = items.firstIndex(where: { $0 == date }) {
            items.remove(at: index)
            datesWithToBeDeleted.append(date)
            datesWith.accept(items)
        }
        
        if let index = datesWithToAdd.firstIndex(where: { $0 == date } ) {
            datesWithToAdd.remove(at: index)
        }
    }
    
    // add an item to an array if its not a duplicate 
    private func addItem<T: ModelDefault, S: ModelDefault>(item: T, itemsToMatchAgainst: [S], appendTo: inout [Int]) {
        if let id = item.id,
            !itemsToMatchAgainst.contains(where: {$0.id == id}) {
            appendTo.append(id)
        }
    }
}

// MARK: - API Methods
extension ViewEditContactViewModel {
    private func getContactInfo(with id: Int) {
        isLoading.accept(true)
        tagService.show(id: id)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.isLoading.accept(false)
                self.setup(for: response)
                self.contact.accept(response)
            }, onError: { error in
                self.isLoading.accept(false)
                let errorObject = error as! ErrorResponseObject
                self.errorStatus.accept(errorObject.status)
           
            }).disposed(by: disposeBag)
    }
    
    func updateTag() {
        isLoading.accept(true)
        let tag = buildTag()
        
        guard tag.isNotEmpty() else {
            print("nothing to update! CYA!")
            isLoading.accept(false)
            self.success.accept(true)
            return
        }
        
        tagService
            .update(tag: tag)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.isLoading.accept(false)
                self.success.accept(true)
            }, onError: { error in
                self.isLoading.accept(false)
                let errorObject = error as! ErrorResponseObject
                self.errorStatus.accept(errorObject.status)
            }).disposed(by: disposeBag)
    }
    
    private func buildTag() -> Tag {
        let tag = Tag()
        
        tag.id = contact.value.id
        
        if name.value != contact.value.title {
            tag.title = name.value
        }
        
        if note.value != contact.value.note {
            tag.note = note.value
        }
        
        if datesWithToAdd.count > 0 {
            tag.datesWith = datesWithToAdd
        }
        
        if datesWithToBeDeleted.count > 0 {
            tag.datesWithToBeDeleted = datesWithToBeDeleted
        }
        
        if tagEventIdsToBeDeleted.count > 0 {
            tag.tagEventIdsToBeDeleted = tagEventIdsToBeDeleted
        }
        
        if tagLookIdsToBeDeleted.count > 0 {
            tag.tagLookIdsToBeDeleted = tagEventIdsToBeDeleted
        }
        
        if tagClothingItemIdsToBeDeleted.count > 0 {
            tag.tagClothingItemIdsToBeDeleted = tagClothingItemIdsToBeDeleted
        }
        
        if eventIdsToAdd.count > 0 {
            tag.eventIds = eventIdsToAdd
        }
        
        if lookIdsToAdd.count > 0 {
            tag.lookIds = lookIdsToAdd
        }
        
        if clothingItemIdsToAdd.count > 0 {
            tag.clothingItemIds = clothingItemIdsToAdd
        }
        
        return tag
    }
    
}
