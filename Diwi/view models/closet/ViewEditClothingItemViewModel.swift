//
//  clothingItemViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 4/17/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewEditClothingItemViewModel {
    
    private let _errorMessage        = BehaviorRelay<String>(value: "")
    private let _isLoading           = BehaviorRelay<Bool>(value: false)
    private let _success             = BehaviorRelay<Bool>(value: false)
    private let _dateAdded           = BehaviorRelay<String>(value: "")
    private let _lookItems           = BehaviorRelay<[Look]>(value: [])
    private let _events              = BehaviorRelay<[Event]>(value: [])
    private let _contacts            = BehaviorRelay<[Tag]>(value: [])
    private let _datesWorn           = BehaviorRelay<[String]>(value: [])
    private let _formValid           = BehaviorRelay<Bool>(value: true)
    private let _viewMode            = BehaviorRelay<ViewingMode>(value: .view)
    private let _mainImage           = BehaviorRelay<String>(value: "")
    private let _itemTypes           = BehaviorRelay<[String]>(value: [])
    private let _navTitle            = BehaviorRelay<String>(value: TextContent.Labels.myItem)
    let title                        = BehaviorRelay<String>(value: "")
    let note                         = BehaviorRelay<String>(value: "")
    let itemType                     = BehaviorRelay<String>(value: "")
    var tags                         = BehaviorRelay<[Tag]>(value: [])
    let itemPhoto                    = BehaviorRelay<UIImageView>(value: UIImageView())
    private let _lookClothingItems   = BehaviorRelay<[LookClothingItem]>(value: [])
    private let _eventClothingItem   = BehaviorRelay<[EventClothingItem]>(value: [])
    private let _clothingItemTags    = BehaviorRelay<[ClothingItemTag]>(value: [])
    
    var isLoading: Driver<Bool> { return _isLoading.asDriver() }
    var errorMessage: Driver<String> { return _errorMessage.asDriver() }
    var success: Driver<Bool> { return _success.asDriver() }
    var dateAdded: Driver<String> { return _dateAdded.asDriver() }
    var lookItems: Driver<[Look]> { return _lookItems.asDriver() }
    var events: Driver<[Event]> { return _events.asDriver() }
    var contacts: Driver<[Tag]> { return _contacts.asDriver() }
    var datesWorn: Driver<[String]> { return _datesWorn.asDriver() }
    var formValid: Driver<Bool> { return _formValid.asDriver() }
    var viewMode: Driver<ViewingMode> { return _viewMode.asDriver() }
    var mainImage: Driver<String> { return _mainImage.asDriver() }
    var itemTypes: Driver<[String]> { return _itemTypes.asDriver() }
    var navTitle: Driver<String> { return  _navTitle.asDriver() }
    
    let disposeBag = DisposeBag()
    private let clothingItemService: ClothingItemInfoService
    private var clothingTypesService: ClothingTypesService
    private let tagService: TagInfoService
    private var originalItem: ClothingItem?
    
    private var lookClothingItemIdsToBeDeleted: [Int] = []
    private var clothingItemTagsIdsToBeDeleted: [Int] = []
    private var eventClothingItemsIdsToBeDeleted: [Int] = []
    private var datesWornToBeDeleted: [String] = []
    
    private var lookIdsToAdd: [Int] = []
    private var tagIdsToAdd: [Int] = []
    private var eventIdsToAdd: [Int] = []
    private var datesWornToAdd: [String] = []
    
    init(id: Int,
         clothingItemService: ClothingItemInfoService,
         clothingTypesService: ClothingTypesService,
         tagService: TagInfoService) {
        self.clothingItemService = clothingItemService
        self.clothingTypesService = clothingTypesService
        self.tagService = tagService
        
        getClothingTypes()
        getItem(with: id)
        getTags()
    }
    
    func validateForm() {
        if !itemType.value.isEmpty && !_mainImage.value.isEmpty {
            _formValid.accept(true)
        } else {
            _formValid.accept(false)
        }
    }
    
    func updateItem() {
        createTags { self.saveItem() }
    }
    
    func resetView() {
        updateViewingMode(to: .view)
        populateView()
    }
}

// MARK: - Convienance methods
extension ViewEditClothingItemViewModel {
    func updateViewingMode(to mode: ViewingMode) {
        _viewMode.accept(mode)
    }
    
    func updateItemPhoto(with imageView: UIImageView) {
        itemPhoto.accept(imageView)
    }
    
    func getViewMode() -> ViewingMode {
        return _viewMode.value
    }
    
    func looksItemsCount() -> Int {
        return _lookItems.value.count
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
    
    func getLookItem(at index: Int) -> Look {
        return _lookItems.value[index]
    }
    
    func getAllItemsFor(_ model: ModelType) -> [ModelDefault] {
        switch model {
        case .Looks:
            return _lookItems.value
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
extension ViewEditClothingItemViewModel {
    private func getClothingTypes() {
        clothingTypesService.index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                guard let clothingTypes = response.clothingTypes else { return }
                let capitalized = clothingTypes.compactMap({ $0.capitalized })
                self._itemTypes.accept(capitalized)
            }, onError: { error in
                if let _ = error as? ErrorResponseObject {
                    self._errorMessage.accept(TextContent.Errors.clothingTypes)
                }
            }).disposed(by: disposeBag)
    }
    
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
    
    private func getItem(with id: Int) {
        _isLoading.accept(true)
        
        clothingItemService.show(id: id)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self._isLoading.accept(false)
                self.originalItem = response
                self.populateView()
            }, onError: { error in
                self._isLoading.accept(false)
                if let _ = error as? ErrorResponseObject {
                    self._errorMessage.accept(TextContent.Errors.couldNotRetrieveLook)
                }
         }).disposed(by: disposeBag)

    }
    
    private func saveItem() {
        _isLoading.accept(true)
        let item = buildItem()
        
        guard item.isNotEmpty() else {
            _isLoading.accept(false)
            _success.accept(true)
            return
        }
        
        clothingItemService.update(clothingItem: item)
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
        guard let clothingItem = originalItem else { return }
        
        if let title = clothingItem.title {
            self.title.accept(title)
        }
        
        if let note = clothingItem.note {
            self.note.accept(note)
        }
        
        if let typeOf = clothingItem.typeOf {
            self.itemType.accept(typeOf.capitalized)
        }
        
        if let events = clothingItem.events {
            _events.accept(events)
        }
        
        if let looks = clothingItem.looks {
            _lookItems.accept(looks)
        }
        
        if let contacts = clothingItem.tags {
            for contact in contacts {
                contact.selected = true
            }
            
            _contacts.accept(contacts)
        }
        
        if let dates = clothingItem.datesWorn {
            _datesWorn.accept(dates)
        }
        
        if let createdAt = clothingItem.createdAtPretty() {
            _dateAdded.accept(createdAt)
        }
        
        if let mainImage = clothingItem.image {
            _mainImage.accept(mainImage)
        }
        
        if let lookClothingItems = clothingItem.lookClothingItems {
            _lookClothingItems.accept(lookClothingItems)
        }
        
        if let itemTags = clothingItem.clothingItemTags {
            _clothingItemTags.accept(itemTags)
        }
        
        if let itemEvents = clothingItem.eventClothingItems {
            _eventClothingItem.accept(itemEvents)
        }
    }
    
    private func buildItem() -> ClothingItem {
        let item = ClothingItem()
        
        if let id = originalItem?.id {
            item.id = id
        }
        
        if let newImage = itemPhoto.value.image {
            item.image = newImage.encodeImageAsBase64Jpeg(compression: 8.0)
        }
        
        if title.value != originalItem?.title {
            item.title = title.value
        }
        
        if itemType.value != originalItem?.typeOf {
            item.typeOf = itemType.value.lowercased()
        }
        
        // do not add if not different from original or is the placeholder text
        if note.value != TextContent.Labels.addANote || note.value != originalItem?.note {
            item.note = note.value
        }
        
        if lookIdsToAdd.count > 0 {
            item.lookIds = lookIdsToAdd
        }
        
        if eventIdsToAdd.count > 0 {
            item.eventIds = eventIdsToAdd
        }
        
        if tagIdsToAdd.count > 0 {
            item.tagIds = tagIdsToAdd
        }
        
        if datesWornToAdd.count > 0 {
            item.datesWorn = datesWornToAdd
        }
        
        if eventClothingItemsIdsToBeDeleted.count > 0 {
            item.eventClothingItemsToBeDeleted = eventClothingItemsIdsToBeDeleted
        }
        
        if clothingItemTagsIdsToBeDeleted.count > 0 {
            item.clothingItemTagsToBeDeleted = clothingItemTagsIdsToBeDeleted
        }
        
        if lookClothingItemIdsToBeDeleted.count > 0 {
            item.lookClothingItemsToBeDeleted = lookClothingItemIdsToBeDeleted
        }
        
        return item
    }
}

// MARK: - Managing Arrays
extension ViewEditClothingItemViewModel {
    func updatelookItems(with items: [Look]) {
        _lookItems.accept(items)
        for item in items {
            addItem(item: item,
                    itemsToMatchAgainst: _lookClothingItems.value,
                    appendTo: &lookIdsToAdd)
        }
    }
    
    func updateEvents(with events: [Event]) {
        _events.accept(events)
        
        for event in events {
            addItem(item: event,
                    itemsToMatchAgainst: _eventClothingItem.value,
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
            addToclothingItemTagsToBeDeleted(with: id)
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
    
    func removeLook(item: Look) {
        var items = _lookItems.value
        if let id = item.id,
            let index = items.firstIndex(where: { $0.id == id}) {
            items.remove(at: index)
            addToLookClothingItemsToBeDeleted(with: id)
            _lookItems.accept(items)
            removeFromAddedArray(with: id, arrayToCheck: &lookIdsToAdd)
        }
    }
    
    func removeEvent(item: Event) {
        var items = _events.value
        if let id = item.id,
            let index = items.firstIndex(where: { $0.id == id}) {
            items.remove(at: index)
            addToeventClothingItemsToBeDeleted(with: id)
            _events.accept(items)
            removeFromAddedArray(with: id, arrayToCheck: &eventIdsToAdd)
        }
    }
    
    private func removeFromAddedArray(with id: Int, arrayToCheck: inout [Int]) {
        if let index = arrayToCheck.firstIndex(where: { $0 == id }) {
            arrayToCheck.remove(at: index)
        }
    }
    
    private func addToeventClothingItemsToBeDeleted(with eventId: Int) {
        if let item = _eventClothingItem.value.first(where: { $0.eventId == eventId }),
            let id = item.id {
            eventClothingItemsIdsToBeDeleted.append(id)
        }
    }
    
    private func addToclothingItemTagsToBeDeleted(with tagId: Int) {
        if let item = _clothingItemTags.value.first(where: { $0.tagId == tagId }),
            let id = item.id {
            clothingItemTagsIdsToBeDeleted.append(id)
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
extension ViewEditClothingItemViewModel: ChooseWhoViewModel {
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
        let existingTags = originalItem?.tags ?? []
        let lookTags = _clothingItemTags.value
        
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
                clothingItemTagsIdsToBeDeleted.append(lookTagId)
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

