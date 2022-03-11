//
//  ViewEditLookViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 4/13/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewEditLookViewModel {
    
    private let _errorMessage        = BehaviorRelay<String>(value: "")
    private let _isLoading           = BehaviorRelay<Bool>(value: false)
    private let _success             = BehaviorRelay<Bool>(value: false)
    private let _dateAdded           = BehaviorRelay<String>(value: "")
    private let _clothingItems       = BehaviorRelay<[ClothingItem]>(value: [])
    private let _events              = BehaviorRelay<[Event]>(value: [])
    private let _contacts            = BehaviorRelay<[Tag]>(value: [])
    private let _datesWorn           = BehaviorRelay<[String]>(value: [])
    private let _formValid           = BehaviorRelay<Bool>(value: true)
    private let _viewMode            = BehaviorRelay<ViewingMode>(value: .view)
    private let _mainImage           = BehaviorRelay<String>(value: "")
    let title                        = BehaviorRelay<String>(value: "")
    let note                         = BehaviorRelay<String>(value: "")
    var tags                         = BehaviorRelay<[Tag]>(value: [])
    private let _lookClothingItems   = BehaviorRelay<[LookClothingItem]>(value: [])
    private let _lookEvents          = BehaviorRelay<[LookEvent]>(value: [])
    private let _lookTags            = BehaviorRelay<[LookTag]>(value: [])
    
    var isLoading: Driver<Bool> { return _isLoading.asDriver() }
    var errorMessage: Driver<String> { return _errorMessage.asDriver() }
    var success: Driver<Bool> { return _success.asDriver() }
    var dateAdded: Driver<String> { return _dateAdded.asDriver() }
    var clothingItems: Driver<[ClothingItem]> { return _clothingItems.asDriver() }
    var events: Driver<[Event]> { return _events.asDriver() }
    var contacts: Driver<[Tag]> { return _contacts.asDriver() }
    var datesWorn: Driver<[String]> { return _datesWorn.asDriver() }
    var formValid: Driver<Bool> { return _formValid.asDriver() }
    var viewMode: Driver<ViewingMode> { return _viewMode.asDriver() }
    var mainImage: Driver<String> { return _mainImage.asDriver() }
    
    let disposeBag = DisposeBag()
    private let lookService: LookInfoService
    private let tagService: TagInfoService
    private var originalLook: Look?
    
    private var lookClothingItemIdsToBeDeleted: [Int] = []
    private var lookTagIdsToBeDeleted: [Int] = []
    private var lookEventIdsToBeDeleted: [Int] = []
    private var datesWornToBeDeleted: [String] = []
    
    private var clothingItemIdsToAdd: [Int] = []
    private var tagIdsToAdd: [Int] = []
    private var eventIdsToAdd: [Int] = []
    private var datesWornToAdd: [String] = []
    
    init(id: Int,
         lookService: LookInfoService,
         tagService: TagInfoService) {
        self.lookService = lookService
        self.tagService = tagService
        getLook(with: id)
        getTags()
    }
    
    func validateForm() {
        if !title.value.isEmpty && _clothingItems.value.count > 0 {
            _formValid.accept(true)
        } else {
            _formValid.accept(false)
        }
    }
    
    func updateLook() {
        self._isLoading.accept(true)
        createTags { self.saveLook() }
    }
    
    func resetView() {
        updateViewingMode(to: .view)
        populateView()
    }
}

// MARK: - Convienance methods
extension ViewEditLookViewModel {
    func updateViewingMode(to mode: ViewingMode) {
        _viewMode.accept(mode)
    }
    
    func getViewMode() -> ViewingMode {
        return _viewMode.value
    }
    
    func clothingItemsCount() -> Int {
        return _clothingItems.value.count
    }
    
    func eventsCount() -> Int {
        return _events.value.count
    }
    
    func contactsCount() -> Int {
        return _contacts.value.count
    }
    
    func datesCount() -> Int {
        return _datesWorn.value.count
    }
    
    func getClothingItem(at index: Int) -> ClothingItem {
        return _clothingItems.value[index]
    }
    
    func getAllItemsFor(_ model: ModelType) -> [ModelDefault] {
        switch model {
        case .ClothingItems:
            return _clothingItems.value
        case .Events:
            return _events.value
        case .Contacts:
            return _contacts.value
        default:
            return []
        }
    }
    
    func getAllDates() -> [String] {
        return _datesWorn.value
    }
    
    func getEvent(at index: Int) -> Event {
        return _events.value[index]
    }
    
    func getContact(at index: Int) -> Tag {
        return _contacts.value[index]
    }
    
    func getDate(at index: Int) -> String {
        return _datesWorn.value[index]
    }
}

// MARK: - API Methods
extension ViewEditLookViewModel {
    private func getTags() {
        guard tags.value.count == 0 else {return}
        
        tagService
            .index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                let sorted = self.sortTagsByTitle(for: response)
                for item in sorted {
                    if let _ = self._contacts.value.first(where: {$0.id == item.id}) {
                        item.selected = true
                    }
                }
                self.tags.accept(sorted)
            }, onError: { error in
                if let _ = error as? ErrorResponseObject {
                    self._errorMessage.accept(TextContent.Errors.tagIndexError)
                }
            }).disposed(by: disposeBag)
    }
    
    private func getLook(with id: Int) {
        _isLoading.accept(true)
        lookService.show(id: id)
         .observeOn(MainScheduler.instance)
         .subscribe(onNext: { response in
            self._isLoading.accept(false)
            self.originalLook = response
            self.populateView()
         }, onError: { error in
             self._isLoading.accept(false)
             if let _ = error as? ErrorResponseObject {
                 self._errorMessage.accept(TextContent.Errors.couldNotRetrieveLook)
             }
         }).disposed(by: disposeBag)

    }
    
    private func saveLook() {
        _isLoading.accept(true)
        let look = buildLook()
        
        guard look.isNotEmpty() else {
            print("nothing to update! CYA!")
            _isLoading.accept(false)
            _success.accept(true)
            return
        }
        
        lookService.update(look: look)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self._isLoading.accept(false)
                self._success.accept(true)
            }, onError: { error in
                self._isLoading.accept(false)
                if let _ = error as? ErrorResponseObject {
                    self._errorMessage.accept(TextContent.Errors.couldNotRetrieveLook)
                }
            }).disposed(by: disposeBag)
    }
    
    private func createTags(completion: @escaping (() -> Void)) {
        guard numberOfTagsToBeCreated() > 0 else {
            completion()
            return
        }
        
        let group = DispatchGroup()
        
        for tag in _contacts.value {
            if tag.id == nil {
                group.enter()
                tagService
                    .create(tag: tag)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { response in
                        if let id = response.id {
                            tag.id = id
                            self.tagIdsToAdd.append(id)
                        }
                        group.leave()
                    }, onError: { error in
                        if let _ = error as? ErrorResponseObject {
                            self._errorMessage.accept(TextContent.Errors.createTagError)
                        }
                        group.leave()
                    }).disposed(by: disposeBag)
            }
        }
        
        group.notify(queue: .main, execute: {
            completion()
        })
    }
    
    private func populateView() {
        guard let look = originalLook else { return }
        
        if let title = look.title {
            self.title.accept(title)
        }
        
        if let note = look.note {
            self.note.accept(note)
        }
        
        if let events = look.events {
            _events.accept(events)
        }
        
        if let clothingItems = look.clothingItems {
            _clothingItems.accept(clothingItems)
        }
        
        if let contacts = look.tags {
            for contact in contacts {
                contact.selected = true
            }
            _contacts.accept(contacts)
        }
        
        if let dates = look.datesWorn {
            _datesWorn.accept(dates)
        }
        
        if let createdAt = look.createdAtPretty() {
            _dateAdded.accept(createdAt)
        }
        
        if let mainImage = look.image {
            _mainImage.accept(mainImage)
        }
        
        if let lookClothingItems = look.lookClothingItems {
            _lookClothingItems.accept(lookClothingItems)
        }
        
        if let lookTags = look.lookTags {
            _lookTags.accept(lookTags)
        }
        
        if let lookEvents = look.lookEvents {
            _lookEvents.accept(lookEvents)
        }
    }
    
    private func buildLook() -> Look {
        let look = Look()
        
        if let id = originalLook?.id {
            look.id = id
        }
        
        if title.value != originalLook?.title {
            look.title = title.value
        }
        
        if note.value != originalLook?.note {
            look.note = note.value
        }
        
        if eventIdsToAdd.count > 0 {
            look.eventIds = eventIdsToAdd
        }
        
        if clothingItemIdsToAdd.count > 0 {
            look.clothingItemIds = clothingItemIdsToAdd
        }
        
        if tagIdsToAdd.count > 0 {
            look.tagIds = tagIdsToAdd
        }
        
        if datesWornToAdd.count > 0 {
            look.datesWorn = datesWornToAdd
        }
        
        if lookEventIdsToBeDeleted.count > 0 {
            look.lookEventIdsToBeDeleted = lookEventIdsToBeDeleted
        }
        
        if lookTagIdsToBeDeleted.count > 0 {
            look.lookTagIdsToBeDeleted = lookTagIdsToBeDeleted
        }
        
        if lookClothingItemIdsToBeDeleted.count > 0 {
            look.lookClothingItemIdsToBeDeleted = lookClothingItemIdsToBeDeleted
        }
        
        return look
    }
}

// MARK: - Managing Arrays
extension ViewEditLookViewModel {
    func updateClothingItems(with items: [ClothingItem]) {
        _clothingItems.accept(items)
        for item in items {
            addItem(item: item,
                    itemsToMatchAgainst: _lookClothingItems.value,
                    appendTo: &clothingItemIdsToAdd)
        }
    }
    
    func updateEvents(with events: [Event]) {
        _events.accept(events)
        
        for event in events {
            addItem(item: event,
                    itemsToMatchAgainst: _lookEvents.value,
                    appendTo: &eventIdsToAdd)
        }
    }
    
    private func formatDateForDateWithString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func updateDates(with date: Date) {
        let dateString = formatDateForDateWithString(date: date)
        var existingItems = _datesWorn.value
        // check if dateString already exists
        if  !existingItems.contains(where: {$0 == dateString}) {
            existingItems.append(dateString)
            datesWornToAdd.append(dateString)
            _datesWorn.accept(existingItems)
        }
    }
    
    func removeContact(contact: Tag) {
        var items = _contacts.value
        if let id = contact.id,
           let index = items.firstIndex(where: { $0.id == id}) {
            contact.selected = false
            items.remove(at: index)
            addToLookTagsToBeDeleted(with: id)
            removeFromAddedArray(with: id, arrayToCheck: &tagIdsToAdd)
            _contacts.accept(items)
        } else if let title = contact.title,
            let index = items.firstIndex(where: { $0.title == title && $0.selected == contact.selected}) {
            contact.selected = false
            items.remove(at: index)
            _contacts.accept(items)
        }
    }
    
    func removeFromDates(date: String) {
        var items = _datesWorn.value
        if let index = items.firstIndex(where: { $0 == date }) {
            items.remove(at: index)
            _datesWorn.accept(items)
        }
    }
    
    func removeClothingItem(item: ClothingItem) {
        var items = _clothingItems.value
        if let id = item.id,
            let index = items.firstIndex(where: { $0.id == id}) {
            items.remove(at: index)
            addToLookClothingItemsToBeDeleted(with: id)
            _clothingItems.accept(items)
            removeFromAddedArray(with: id, arrayToCheck: &clothingItemIdsToAdd)
        }
    }
    
    func removeEvent(item: Event) {
        var items = _events.value
        if let id = item.id,
            let index = items.firstIndex(where: { $0.id == id}) {
            items.remove(at: index)
            addToLookEventItemsToBeDeleted(with: id)
            _events.accept(items)
            removeFromAddedArray(with: id, arrayToCheck: &eventIdsToAdd)
        }
    }
    
    private func removeFromAddedArray(with id: Int, arrayToCheck: inout [Int]) {
        if let index = arrayToCheck.firstIndex(where: { $0 == id }) {
            arrayToCheck.remove(at: index)
        }
    }
    
    private func addToLookEventItemsToBeDeleted(with eventId: Int) {
        if let item = _lookEvents.value.first(where: { $0.eventId == eventId }),
            let id = item.id {
            lookEventIdsToBeDeleted.append(id)
        }
    }
    
    private func addToLookTagsToBeDeleted(with tagId: Int) {
        if let item = _lookTags.value.first(where: { $0.tagId == tagId }),
            let id = item.id {
            lookTagIdsToBeDeleted.append(id)
        }
    }
    
    private func addToLookClothingItemsToBeDeleted(with clothingId: Int) {
        if let item = _lookClothingItems.value.first(where: { $0.clothingItemId == clothingId }),
            let id = item.id {
            lookClothingItemIdsToBeDeleted.append(id)
        }
    }
    
    func removeFromDateWith(date: String) {
        var items = _datesWorn.value
        if let index = items.firstIndex(where: { $0 == date }) {
            items.remove(at: index)
            datesWornToBeDeleted.append(date)
            _datesWorn.accept(items)
        }
        
        if let index = datesWornToAdd.firstIndex(where: { $0 == date } ) {
            datesWornToAdd.remove(at: index)
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


// MARK: - Tag methods and logic
extension ViewEditLookViewModel: ChooseWhoViewModel {
    func updateTagsArray(newName: String) {
        createNewTag(with: newName)
        setSelectedTags()
        updateTagsToBeAddedOrRemoved()
    }
    
    func setSelectedTags() {
        _contacts.accept(tags.value.filter {$0.selected} )
    }
    
    func updateTagsToBeAddedOrRemoved() {
        let tags = _contacts.value
        let existingTags = originalLook?.tags ?? []
        let lookTags = _lookTags.value
        
        for tag in tags {
            guard let id = tag.id else { return }
            if !existingTags.contains(where: {$0.id == id }) && !tagIdsToAdd.contains { $0 == id } {
                tagIdsToAdd.append(id)
            }
        }
        
        for tag in existingTags {
            guard let id = tag.id else { return }
            if !tags.contains(where: {$0.id == id }),
                let lookTag = lookTags.first(where: {$0.tagId == id}),
                let lookTagId = lookTag.id {
                lookTagIdsToBeDeleted.append(lookTagId)
            }
        }
    }
    
    private func createNewTag(with name: String) {
        guard !name.isEmpty else { return }
        
        let newTag = Tag()
        newTag.title = name
        newTag.selected = true
        
        let allTags = tags.value + [newTag]
        let sortedTags = sortTagsByTitle(for: allTags)
        
        tags.accept(sortedTags)
    }
    
    func numberOfTagsToBeCreated() -> Int {
        return _contacts.value.filter({ $0.id == nil }).count
    }
    
    private func sortTagsByTitle(for tags: [Tag]) -> [Tag] {
        
        return tags.sorted(by: { (a, b) -> Bool in
            a.title! < b.title!
        })
    }
}
