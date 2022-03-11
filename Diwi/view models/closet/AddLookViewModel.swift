//
//  AddLookViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 4/9/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct AddLookViewModel {
    private let _errorMessage        = BehaviorRelay<String>(value: "")
    private let _isLoading           = BehaviorRelay<Bool>(value: false)
    private let _success             = BehaviorRelay<Bool>(value: false)
    private let _dateAdded           = BehaviorRelay<String>(value: "")
    private let _clothingItems       = BehaviorRelay<[ClothingItem]>(value: [])
    private let _events              = BehaviorRelay<[Event]>(value: [])
    private let _contacts            = BehaviorRelay<[Tag]>(value: [])
    private let _dates               = BehaviorRelay<[String]>(value: [])
    private let _formValid           = BehaviorRelay<Bool>(value: false)
    private let _createdLook         = BehaviorRelay<Look>(value: Look())
    let title                        = BehaviorRelay<String>(value: "")
    let note                         = BehaviorRelay<String>(value: "")
    var tags                         = BehaviorRelay<[Tag]>(value: [])
    
    var isLoading: Driver<Bool> { return _isLoading.asDriver() }
    var errorMessage: Driver<String> { return _errorMessage.asDriver() }
    var success: Driver<Bool> { return _success.asDriver() }
    var dateAdded: Driver<String> { return _dateAdded.asDriver() }
    var clothingItems: Driver<[ClothingItem]> { return _clothingItems.asDriver() }
    var events: Driver<[Event]> { return _events.asDriver() }
    var contacts: Driver<[Tag]> { return _contacts.asDriver() }
    var dates: Driver<[String]> { return _dates.asDriver() }
    var formValid: Driver<Bool> { return _formValid.asDriver() }
    
    let disposeBag = DisposeBag()
    private let lookService: LookInfoService
    private let tagService: TagInfoService
    private let _workflow: Workflow
    
    init(lookService: LookInfoService,
         tagService: TagInfoService,
         workflow: Workflow) {
        self.lookService = lookService
        self.tagService = tagService
        self._workflow = workflow
        setDateAdded()
        getTags()
    }
    
    private func setDateAdded() {
        let df = DateFormatter()
        df.dateFormat = "MMM d yyyy  hh:mm:ss"
        let dateString = df.string(from: Date())
        print("date string: \(dateString)")
        _dateAdded.accept(dateString)
    }
    
    func validateForm() {
        if !title.value.isEmpty && _clothingItems.value.count > 0 {
            _formValid.accept(true)
        } else {
            _formValid.accept(false)
        }
    }
    
    func createLook() {
        self._isLoading.accept(true)
        createTags { self.saveLook() }
    }
}

// MARK: - Convienance methods
extension AddLookViewModel {
    func clothingItemsCount() -> Int {
        return _clothingItems.value.count
    }
    
    func getWorkflow() -> Workflow {
        return _workflow
    }
    
    func eventsCount() -> Int {
        return _events.value.count
    }
    
    func contactsCount() -> Int {
        return _contacts.value.count
    }
    
    func datesCount() -> Int {
        return _dates.value.count
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
        return _dates.value
    }
    
    func getEvent(at index: Int) -> Event {
        return _events.value[index]
    }
    
    func getContact(at index: Int) -> Tag {
        return _contacts.value[index]
    }
    
    func getDate(at index: Int) -> String {
        return _dates.value[index]
    }
    
    func updateClothingItems(with items: [ClothingItem]) {
        _clothingItems.accept(items)
    }
    
    func updateEvents(with events: [Event]) {
        _events.accept(events)
    }
    
    private func formatDateForDateWithString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func updateDates(with date: Date) {
        let dateString = formatDateForDateWithString(date: date)
        var existingItems = _dates.value
        // check if dateString already exists
        if  !existingItems.contains(where: {$0 == dateString}) {
            existingItems.append(dateString)
            _dates.accept(existingItems)
        }
    }
    
    func removeClothingItem(item: ClothingItem) {
        var items = _clothingItems.value
        if let id = item.id,
            let index = items.firstIndex(where: { $0.id == id}) {
            items.remove(at: index)
            _clothingItems.accept(items)
        }
    }
    
    func removeEvent(item: Event) {
        var items = _events.value
        if let id = item.id,
            let index = items.firstIndex(where: { $0.id == id}) {
            items.remove(at: index)
            _events.accept(items)
        }
    }
    
    func removeContact(contact: Tag) {
        var items = _contacts.value
        if let id = contact.id,
           let index = items.firstIndex(where: { $0.id == id}) {
            contact.selected = false
            items.remove(at: index)
            _contacts.accept(items)
        } else if let title = contact.title,
            let index = items.firstIndex(where: { $0.title == title && $0.selected == contact.selected}) {
            contact.selected = false
            items.remove(at: index)
            _contacts.accept(items)
        }
    }
    
    func removeFromDates(date: String) {
        var items = _dates.value
        if let index = items.firstIndex(where: { $0 == date }) {
            items.remove(at: index)
            _dates.accept(items)
        }
    }
    
    func getCreatedLook() -> Look {
        return _createdLook.value
    }
}

// MARK: - API Methods
extension AddLookViewModel {
    private func getTags() {
        guard tags.value.count == 0 else {return}
        
        tagService
            .index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                let sorted = self.sortTagsByTitle(for: response)
                self.tags.accept(sorted)
            }, onError: { error in
                if let _ = error as? ErrorResponseObject {
                    self._errorMessage.accept(TextContent.Errors.tagIndexError)
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
    
    private func saveLook() {
        let look = buildLook()
        
        lookService.create(look: look)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self._isLoading.accept(false)
                self._createdLook.accept(response)
                self._success.accept(true)
            }, onError: { error in
                self._isLoading.accept(false)
                if let _ = error as? ErrorResponseObject {
                    self._errorMessage.accept(TextContent.Errors.createLookError)
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func buildLook() -> Look {
        let look = Look()
        
        look.title = title.value
        look.note  = note.value
        
        if datesCount() > 0 {
            look.datesWorn = _dates.value
        }
        
        if eventsCount() > 0 {
            look.eventIds = _events.value.map { $0.id! }
        }
        
        if clothingItemsCount() > 0 {
            look.clothingItemIds = _clothingItems.value.map { $0.id! }
        }
        
        if contactsCount() > 0 {
            look.tagIds = _contacts.value.map { $0.id! }
        }
        
        return look
    }
}

// MARK: - Tag methods and logic
extension AddLookViewModel: ChooseWhoViewModel {
    func updateTagsArray(newName: String) {
        createNewTag(with: newName)
        setSelectedTags()
    }
    
    func setSelectedTags() {
        _contacts.accept(tags.value.filter {$0.selected} )
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
