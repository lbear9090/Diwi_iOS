//
//  AddEventViewModel.swift
//  Diwi
//
//  Created by Jae Lee on 10/25/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct AddEventViewModel: EditEventOrAddEventViewModel,
                          ChooseWhoViewModel {
    var date:Date = Date() {
        didSet {
            let dateString = formatDateForEventDate(date: date)
            eventDate.accept(dateString)
        }
    }
    let dateMonth                 = BehaviorRelay<String>(value: "")
    let dateDay                   = BehaviorRelay<String>(value: "")
    let event                     = BehaviorRelay<Event>(value: Event())
    let time                      = BehaviorRelay<String>(value: "")
    let name                      = BehaviorRelay<String>(value: "")
    let attendees                 = BehaviorRelay<[String]>(value: [])
    let location                  = BehaviorRelay<String>(value: "")
    var address                   = BehaviorRelay<String>(value: "")
    var city                      = BehaviorRelay<String>(value: "")
    var zip                       = BehaviorRelay<String>(value: "")
    var state                     = BehaviorRelay<String>(value: "")
    let dateAdded                 = BehaviorRelay<String>(value: "")
    let eventDate                 = BehaviorRelay<String>(value: "")
    let note                      = BehaviorRelay<String>(value: "")
    var tags                      = BehaviorRelay<[Tag]>(value: [])
    let contacts                  = BehaviorRelay<[Tag]>(value: [])
    let closetItems               = BehaviorRelay<[ClosetItem]>(value: [])
    let clothingItems             = BehaviorRelay<[ClothingItem]>(value: [])
    let looks                     = BehaviorRelay<[Look]>(value: [])
    let isLoading                 = BehaviorRelay<Bool>(value: false)
    let formIsValid               = BehaviorRelay<Bool>(value: false)
    let success                   = BehaviorRelay<Bool>(value: false)
    let errorStatus               = BehaviorRelay<Int>(value: 0)
    let errorMsg                  = BehaviorRelay<String>(value: "")
    let dateFormatter             = DateFormatter()
    
    private let eventService: EventInfoService
    private let clothingItemService: ClothingItemService
    private let tagService: TagInfoService
    private var newClothingItem: ClothingItem?
    
    let disposebag = DisposeBag()
    
    init(eventService: EventInfoService,
         clothingItemService: ClothingItemService,
         tagService: TagInfoService,
         newClothingItem: ClothingItem? = nil) {
        self.eventService = eventService
        self.clothingItemService = clothingItemService
        self.tagService = tagService
        self.newClothingItem = newClothingItem
        
        formatDateEventCreated(for: Date())
        
        getTags()
        
    }
    
    func createEvent() {
        self.isLoading.accept(true)
        createTags(completion: { self.saveEvent() })
    }
    
    func vaidateForm() {
        if validForm() {
            formIsValid.accept(true)
        }
    }
    
    private func validForm() -> Bool {
        return !time.value.isEmpty
    }
}

// MARK: - Convienance Methods
extension AddEventViewModel {
    private func formatDateForEventDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
    
    func formatDateEventCreated(for date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy HH:mm:ss"
        let dateAsString = dateFormatter.string(from: date)
        
        dateAdded.accept(dateAsString)
    }
    
    func contactsCount() -> Int {
        return contacts.value.count
    }
    
    func closetItemsCount() -> Int {
        return closetItems.value.count
    }
    
    func clothingItemsCount() -> Int {
        return clothingItems.value.count
    }
    
    func looksCount() -> Int {
        return looks.value.count
    }
    
    func getClosetItem(at index: Int) -> ClosetItem {
        return closetItems.value[index]
    }
    
    func getClothingItem(at index: Int) -> ClothingItem {
        return clothingItems.value[index]
    }
    
    func getLook(at index: Int) -> Look {
        return looks.value[index]
    }
    
    func getContact(at index: Int) -> Tag {
        return contacts.value[index]
    }
    
    func getAllItemsFor(_ model: ModelType) -> [ModelDefault] {
        switch model {
        case .ClothingItems:
            return clothingItems.value
        case .Contacts:
            return contacts.value
        case .Looks:
            return looks.value
        default:
            return []
        }
    }
    
    mutating func updateDateWith(with date: Date) {
        self.date = date
    }
    
    func updateLooks(with items: [Look]) {
        looks.accept(items)
        updateClosetItems()
    }
    
    func updateClothingItems(with items: [ClothingItem]) {
        clothingItems.accept(items)
        updateClosetItems()
    }
    
    private func updateClosetItems() {
        let items = clothingItems.value
        let looks = self.looks.value
        var closetItems: [ClosetItem] = []
        closetItems.append(contentsOf: items)
        closetItems.append(contentsOf: looks)
       
        self.closetItems.accept(closetItems)
    }
    
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
            clothingItems.accept(items)
        }
    }
    
    private func removeLook(look: Look) {
        var looks = self.looks.value
        if let id = look.id,
            let index = looks.firstIndex(where: { $0.id == id}) {
            looks.remove(at: index)
            self.looks.accept(looks)
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
}

// MARK: - Create Event
extension AddEventViewModel {
    private func saveEvent() {
        let event: Event = buildEvent()
        
        eventService
            .create(event: event)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.isLoading.accept(false)
                self.success.accept(true)
            }, onError: { error in
                self.isLoading.accept(false)
                let errorObject = error as! ErrorResponseObject
                self.errorStatus.accept(errorObject.status)
            }).disposed(by: disposebag)
    }
    
    private func buildEvent() -> Event {
        let event = Event()
        
        event.name = name.value
        event.note = note.value
        
        
        if !location.value.isEmpty {
          event.location = buildLocation()
        }
        
        if looksCount() > 0 {
            event.lookIds = looks.value.map { $0.id! }
        }
        
        if contactsCount() > 0 {
            event.tagIds = contacts.value.map { $0.id! }
        }
        
        if clothingItemsCount() > 0 {
            event.clothingItemIds = clothingItems.value.map { $0.id! }
        }
        
        event.date = mergeDateWithTimeSelected()
        
        return event
    }
    
    private func buildLocation() -> Location {
        let location = Location()
        location.address = address.value
        location.city    = city.value
        location.postalCode = zip.value
        location.state   = state.value
        
        return location
    }
    
    private func mergeDateWithTimeSelected() -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let yearMonthDay = dateFormatter.string(from: date)
        let time = self.time.value
        let fullDateTimeString = yearMonthDay + " " + time
        
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        
        if let fullDate = dateFormatter.date(from: fullDateTimeString) {
            
            return fullDate
        } else {
            return date
        }
        
    }
}

// MARK: - Tag API methods and logic
extension AddEventViewModel {
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

// MARK: - Location Form
extension AddEventViewModel {
    func setAddress() {
        location.accept(addressAsAString())
    }
    
    func validateAddressFields() -> Bool {
        return !address.value.isEmpty &&
               !city.value.isEmpty &&
               !zip.value.isEmpty &&
               !state.value.isEmpty
    }
    
    private func addressAsAString() -> String {
        let addressComponents = [address.value, city.value, state.value, zip.value]
        let addressString = addressComponents.joined(separator: ", ")
        return addressString
    }
}

