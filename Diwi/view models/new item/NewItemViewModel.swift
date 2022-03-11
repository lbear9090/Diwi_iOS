//
//  NewItemViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 9/4/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NewItemViewModel {
    let savedClothingItem  = BehaviorRelay<ClothingItem>(value: ClothingItem())
    let itemPhoto          = BehaviorRelay<UIImage>(value: UIImage())
    let itemTitle          = BehaviorRelay<String>(value: "")
    let note               = BehaviorRelay<String>(value: "")
    let itemType           = BehaviorRelay<String>(value: "")
    let dateAdded          = BehaviorRelay<String>(value: "")
    let itemTypes          = BehaviorRelay<[String]>(value: [])
    let looks              = BehaviorRelay<[Look]>(value: [])
    let events             = BehaviorRelay<[Event]>(value: [])
    let contacts           = BehaviorRelay<[Tag]>(value: [])
    let tags               = BehaviorRelay<[Tag]>(value: [])
    let datesWorn          = BehaviorRelay<[String]>(value: [])
    let formValid          = BehaviorRelay<Bool>(value: false)
    let success            = BehaviorRelay<Bool>(value: false)
    let isLoading          = BehaviorRelay<Bool>(value: false)
    let validationErrorMsg = BehaviorRelay<String>(value: "")
    let errorMsg           = BehaviorRelay<String>(value: "")
    let navTitle           = BehaviorRelay<String>(value: TextContent.Labels.newItem)
    let disposebag         = DisposeBag()
    private let workflow   = BehaviorRelay<Workflow>(value: .addClosetItem)
    
    private var clothingTypesService: ClothingTypesService
    private var clothingItemService: ClothingItemService
    private let tagService: TagInfoService
    
    init(clothingTypesService: ClothingTypesService,
         clothingItemService: ClothingItemService,
         tagService: TagInfoService,
         workflow: Workflow) {
        self.clothingTypesService = clothingTypesService
        self.clothingItemService = clothingItemService
        self.tagService = tagService
        self.workflow.accept(workflow)
        
        getClothingTypes()
        getTags()
    }

    func formatDatePhotoTaken(for date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy HH:mm:ss"
        let dateAsString = dateFormatter.string(from: date)
        
        dateAdded.accept(dateAsString)
    }
    
    func validateForm() {
        if !itemType.value.isEmpty {
            formValid.accept(true)
        } else {
            formValid.accept(false)
        }
    }
    
    func save() {
        createTags { self.saveItem() }
    }
}

// MARK: - Convienance methods
extension NewItemViewModel {
    func getCurrentWorkflow() -> Workflow {
        return self.workflow.value
    }

    func looksCount() -> Int {
        return looks.value.count
    }
    
    func eventsCount() -> Int {
        return events.value.count
    }
    
    func contactsCount() -> Int {
        return contacts.value.count
    }
    
    func datesCount() -> Int {
        return datesWorn.value.count
    }
    
    func getLook(at index: Int) -> Look {
        return looks.value[index]
    }
    
    func getAllItemsFor(_ model: ModelType) -> [ModelDefault] {
        switch model {
        case .Looks:
            return looks.value
        case .Events:
            return events.value
        case .Contacts:
            return contacts.value
        default:
            return []
        }
    }
    
    func getAllDates() -> [String] {
        return datesWorn.value
    }
    
    func getEvent(at index: Int) -> Event {
        return events.value[index]
    }
    
    func getContact(at index: Int) -> Tag {
        return contacts.value[index]
    }
    
    func getDate(at index: Int) -> String {
        return datesWorn.value[index]
    }
    private func formatDateForDateWithString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func updateLooks(with items: [Look]) {
        looks.accept(items)
    }
    
    func updateEvents(with events: [Event]) {
        self.events.accept(events)
    }
    
    func updateDates(with date: Date) {
        let dateString = formatDateForDateWithString(date: date)
        var existingItems = datesWorn.value
        // check if dateString already exists
        if  !existingItems.contains(where: {$0 == dateString}) {
            existingItems.append(dateString)
            datesWorn.accept(existingItems)
        }
    }
    
    func removeLook(item: Look) {
        var items = looks.value
        if let id = item.id,
            let index = items.firstIndex(where: { $0.id == id}) {
            items.remove(at: index)
            looks.accept(items)
        }
    }
    
    func removeEvent(item: Event) {
        var items = events.value
        if let id = item.id,
            let index = items.firstIndex(where: { $0.id == id}) {
            items.remove(at: index)
            events.accept(items)
        }
    }
    
    func removeContact(contact: Tag) {
        var items = contacts.value
        if let id = contact.id,
           let index = items.firstIndex(where: { $0.id == id}) {
            contact.selected = false
            items.remove(at: index)
            contacts.accept(items)
        } else if let title = contact.title,
            let index = items.firstIndex(where: { $0.title == title && $0.selected == contact.selected}) {
            contact.selected = false
            items.remove(at: index)
            contacts.accept(items)
        }
    }
    
    func removeFromDates(date: String) {
        var items = datesWorn.value
        if let index = items.firstIndex(where: { $0 == date }) {
            items.remove(at: index)
            datesWorn.accept(items)
        }
    }
}

// MARK: - API Methods
extension NewItemViewModel {
    private func getTags() {
        guard tags.value.count == 0 else {return}
        
        tagService
            .index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                let sorted = self.sortTagsByTitle(for: response)
                for item in sorted {
                    if let _ = self.contacts.value.first(where: {$0.id == item.id}) {
                        item.selected = true
                    }
                }
                self.tags.accept(sorted)
            }, onError: { error in
                if let _ = error as? ErrorResponseObject {
                    self.errorMsg.accept(TextContent.Errors.tagIndexError)
                }
            }).disposed(by: disposebag)
    }
    
    private func getClothingTypes() {
        clothingTypesService.index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                guard let clothingTypes = response.clothingTypes else { return }
                let capitalized = clothingTypes.compactMap({ $0.capitalized })
                self.itemTypes.accept(capitalized)
            }, onError: { error in
                if let _ = error as? ErrorResponseObject {
                    self.errorMsg.accept(TextContent.Errors.clothingTypes)
                }
            }).disposed(by: disposebag)
    }
    
    private func createTags(completion: @escaping (() -> Void)) {
        guard numberOfTagsToBeCreated() > 0 else {
            completion()
            return
        }
        
        let group = DispatchGroup()
        
        for tag in contacts.value {
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
                            self.errorMsg.accept(TextContent.Errors.createTagError)
                        }
                        group.leave()
                    }).disposed(by: disposebag)
            }
        }
        
        group.notify(queue: .main, execute: {
            completion()
        })
    }
    
    func saveItem() {
        let item = buildClothingItem()
        
        isLoading.accept(true)
        clothingItemService.create(clothingItem: item)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                if let id = response.id {
                    item.id = id
                    // replace base64 string with updated AWS url
                    item.image = response.image
                    self.savedClothingItem.accept(item)
                    self.isLoading.accept(false)
                    self.success.accept(true)
                }
            }, onError: { error in
                self.isLoading.accept(false)
                if let _ = error as? ErrorResponseObject {
                    self.errorMsg.accept(TextContent.Errors.savingClothingItem)
                }
            }).disposed(by: disposebag)
    }
    
    private func buildClothingItem() -> ClothingItem {
        let item = ClothingItem()
        
        item.image = itemPhoto.value.encodeImageAsBase64Jpeg(compression: 8.0)
        item.typeOf = itemType.value.lowercased()
        item.title = itemTitle.value
        item.note = note.value
        
        if datesCount() > 0 {
            item.datesWorn = datesWorn.value
        }
        
        if eventsCount() > 0 {
            item.eventIds = events.value.map { $0.id! }
        }
        
        if looksCount() > 0 {
            item.lookIds = looks.value.map { $0.id! }
        }
        
        if contactsCount() > 0 {
            item.tagIds = contacts.value.map { $0.id! }
        }
        
        return item
    }
}

// MARK: - Tag methods and logic
extension NewItemViewModel: ChooseWhoViewModel {
    func updateTagsArray(newName: String) {
        createNewTag(with: newName)
        setSelectedTags()
    }
    
    func setSelectedTags() {
        contacts.accept(tags.value.filter {$0.selected} )
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
        return contacts.value.filter({ $0.id == nil }).count
    }
    
    private func sortTagsByTitle(for tags: [Tag]) -> [Tag] {
        
        return tags.sorted(by: { (a, b) -> Bool in
            a.title! < b.title!
        })
    }
}

