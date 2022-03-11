//
//  EditEventViewModel.swift
//  Diwi
//
//  Created by Jae Lee on 10/25/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ViewEditEventViewModel: EditEventOrAddEventViewModel,
                                ChooseWhoViewModel {
    var date: Date = Date() {
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
    let location                  = BehaviorRelay<String>(value: "")
    let fullAddress               = BehaviorRelay<String>(value: "")
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
    let eventTags                 = BehaviorRelay<[EventTag]>(value: [])
    let lookEvents                = BehaviorRelay<[LookEvent]>(value: [])
    let eventClothingItems        = BehaviorRelay<[EventClothingItem]>(value: [])
    let viewMode                  = BehaviorRelay<ViewingMode>(value: .view)
    
    private let eventService: EventInfoService
    private let clothingItemService: ClothingItemService
    private let tagService: TagInfoService
    private var newClothingItem: ClothingItem?
    private var originalEvent: Event?
    private var workflow: Workflow?
    private let dateFormatter = DateFormatter()
    
    private var eventClothingItemIdsToBeDeleted: [Int] = []
    private var lookEventIdsToBeDeleted: [Int] = []
    private var eventTagsIdsToBeDeleted: [Int] = []
    
    private var clothingItemIdsToAdd: [Int] = []
    private var lookIdsToAdd: [Int] = []
    private var tagIdsToAdd: [Int] = []
    
    let disposebag = DisposeBag()
    
    init(eventService: EventInfoService,
         clothingItemService: ClothingItemService,
         tagService: TagInfoService,
         newClothingItem: ClothingItem? = nil,
         id: Int,
         workflow: Workflow) {
        
        self.eventService = eventService
        self.clothingItemService = clothingItemService
        self.tagService = tagService
        self.newClothingItem = newClothingItem
        self.workflow = workflow
        
        formatDateEventCreated(for: Date())
        getEvent(with: id)
        getTags()
        
        if workflow == .editEvent {
            updateViewingMode(to: .edit)
        }
    }
    
    func resetView() {
        updateViewingMode(to: .view)
        guard let event = originalEvent else { return }
        setup(for: event)
    }
    
    func updateEvent() {
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
extension ViewEditEventViewModel {
    func getViewMode() -> ViewingMode {
        return viewMode.value
    }
    
    func updateViewingMode(to mode: ViewingMode) {
        viewMode.accept(mode)
    }
    
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
    
    func updateDateWith(with date: Date) {
        self.date = date
    }
    
    func updateLooks(with items: [Look]) {
        looks.accept(items)
        
        for look in items {
            addItem(item: look,
                    itemsToMatchAgainst: lookEvents.value,
                    appendTo: &lookIdsToAdd)
        }
        
        updateClosetItems()
    }
    
    func updateClothingItems(with items: [ClothingItem]) {
        clothingItems.accept(items)
        
        for item in items {
            addItem(item: item,
                    itemsToMatchAgainst: eventClothingItems.value,
                    appendTo: &clothingItemIdsToAdd)
        }
        
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
            addToEventClothingItemsToBeDeleted(with: id)
            removeFromAddedArray(with: id, arrayToCheck: &clothingItemIdsToAdd)
        }
    }
    
    private func addToEventClothingItemsToBeDeleted(with clothingId: Int) {
        if let item = eventClothingItems.value.first(where: { $0.clothingItemId == clothingId }),
            let id = item.id {
            eventClothingItemIdsToBeDeleted.append(id)
        }
    }
    
    private func removeLook(look: Look) {
        var looks = self.looks.value
        if let id = look.id,
            let index = looks.firstIndex(where: { $0.id == id}) {
            looks.remove(at: index)
            self.looks.accept(looks)
            addToLookEventsToBeDeleted(with: id)
            removeFromAddedArray(with: id, arrayToCheck: &lookIdsToAdd)
        }
    }
    
    private func addToLookEventsToBeDeleted(with lookId: Int) {
        if let item = lookEvents.value.first(where: { $0.lookId == lookId }),
            let id = item.id {
            lookEventIdsToBeDeleted.append(id)
        }
    }
    
    func removeContact(contact: Tag) {
        var items = contacts.value
        if let id = contact.id,
           let index = items.firstIndex(where: { $0.id == id}) {
            contact.selected = false
            items.remove(at: index)
            addToEventTagsToBeDeleted(with: id)
            removeFromAddedArray(with: id, arrayToCheck: &tagIdsToAdd)
            contacts.accept(items)
        } else if let title = contact.title,
            let index = items.firstIndex(where: { $0.title == title && $0.selected == contact.selected}) {
            contact.selected = false
            items.remove(at: index)
            contacts.accept(items)
        }
    }
    
    private func addToEventTagsToBeDeleted(with tagId: Int) {
        if let item = eventTags.value.first(where: { $0.tagId == tagId }),
            let id = item.id {
            eventTagsIdsToBeDeleted.append(id)
        }
    }
    
    private func removeFromAddedArray(with id: Int, arrayToCheck: inout [Int]) {
        if let index = arrayToCheck.firstIndex(where: { $0 == id }) {
            arrayToCheck.remove(at: index)
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


// MARK: - Get Event
extension ViewEditEventViewModel {
    private func getEvent(with id: Int) {
        isLoading.accept(true)
        eventService.show(id: id)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { event in
                self.event.accept(event)
                self.originalEvent = event
                self.setup(for: event)
                self.isLoading.accept(false)
            }, onError: { error in
                self.isLoading.accept(false)
                if error is ErrorResponseObject {
                    self.errorMsg.accept(TextContent.Errors.couldNotRetrieveEvent)
                }
            }).disposed(by: disposebag)
    }
    
    private func setup(for event: Event) {
    
        if let date = event.date {
            self.date = date
        }
    
        if let note = event.note {
            self.note.accept(note)
        }
        
        if let name = event.name {
            self.name.accept(name)
        }
    
        if let tags = event.tags {
            for tag in tags {
                tag.selected = true
            }
            contacts.accept(tags)
            
            // update all tags which have already been selected for event
            let allTags = self.tags.value
            let selectedAllTags = self.initializeSelectedTags(with: allTags)
            self.tags.accept(selectedAllTags)
        }
        
        if let looks = event.looks {
            self.looks.accept(looks)
        }
        
        if let clothingItems = event.clothingItems {
            self.clothingItems.accept(clothingItems)
        }
    
        if let eventTags = event.eventTags {
            self.eventTags.accept(eventTags)
        }
    
        if let time = event.timeOfDay() {
            self.time.accept(time)
        }
    
        if let items = event.eventClothingItems {
            self.eventClothingItems.accept(items)
        }
      
        updateClosetItems()
    
        guard let location = event.location else {
            setFullAddress()
            return }
    
        if let addressOne = location.address {
            address.accept(addressOne)
        }
    
        if let city = location.city,
            let state = location.state,
            let zip = location.postalCode {
            self.city.accept(city)
            self.state.accept(state)
            self.zip.accept(zip)
        }
    
        setFullAddress()
    }
    
    func setFullAddress() {
        if validateAddressFields() {
            fullAddress.accept("\(address.value),\(city.value), \(state.value), \(zip.value)")
        }
    }
}

// MARK: - Create Event
extension ViewEditEventViewModel {
    private func saveEvent() {
        let event: Event = buildEvent()
        
        guard event.isNotEmpty() else {
            print("nothing to update! CYA!")
            self.success.accept(true)
            return
        }
        
        self.isLoading.accept(true)
        
        eventService
            .edit(event: event)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.isLoading.accept(false)
                self.success.accept(true)
            }, onError: { error in
                self.isLoading.accept(false)
                if error is ErrorResponseObject {
                    self.errorMsg.accept(TextContent.Errors.updateClothingItem)
                }
            }).disposed(by: disposebag)
    }
    
    // only send fields that have changed value
    private func buildEvent() -> Event {
        let event = Event()
        
        event.id = self.originalEvent?.id
        
        if name.value != originalEvent?.name {
            event.name = name.value
        }
        
        if note.value != TextContent.Labels.addANote ||
            note.value != self.originalEvent?.note {
            event.note = note.value
        }

        if date != mergeDateWithTimeSelected() {
            event.date = mergeDateWithTimeSelected()
        }

        if buildLocation().isNotEmpty() {
            event.location = buildLocation()
        }

        if tagIdsToAdd.count > 0 {
           event.tagIds = tagIdsToAdd
        }
        
        if lookIdsToAdd.count > 0 {
            event.lookIds = lookIdsToAdd
        }
        
        if clothingItemIdsToAdd.count > 0 {
            event.clothingItemIds = clothingItemIdsToAdd
        }
        
        if eventClothingItemIdsToBeDeleted.count > 0 {
            event.eventClothingItemIdsToBeDeleted = eventClothingItemIdsToBeDeleted
        }
        
        if lookEventIdsToBeDeleted.count > 0 {
            event.lookEventIdsToBeDeleted = lookEventIdsToBeDeleted
        }
        
        if eventTagsIdsToBeDeleted.count > 0 {
            event.eventTagIdsToBeDeleted = eventTagsIdsToBeDeleted
        }

        return event
    }
    
    private func buildLocation() -> Location {
        // only update fields that have changed
        let location = Location()
        let currentEventLocation = self.event.value.location

        location.id = currentEventLocation?.id

        if let currentAddress = currentEventLocation?.address,
            currentAddress != address.value {
            location.address = address.value
        } else if currentEventLocation?.address == nil,
            !address.value.isEmpty {
            location.address = address.value
        }

        if let currentCity = currentEventLocation?.city,
            currentCity != city.value {
            location.city = city.value
        } else if currentEventLocation?.city == nil,
            !city.value.isEmpty {
            location.city = city.value
        }

        if let currentZip = currentEventLocation?.postalCode,
            currentZip != zip.value {
            location.postalCode = zip.value
        } else if currentEventLocation?.postalCode == nil,
            !zip.value.isEmpty {
            location.postalCode = zip.value
        }

        if let currentState = currentEventLocation?.state,
            currentState != state.value {
            location.state = state.value
        } else if currentEventLocation?.state == nil,
            !state.value.isEmpty {
            location.state = state.value
        }

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
extension ViewEditEventViewModel {
    private func getTags() {
        guard tags.value.count == 0 else {return}
           
        tagService
            .index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                let sorted = self.sortTagsByTitle(for: response)
                let sortedAndSelected = self.initializeSelectedTags(with: sorted)
                self.tags.accept(sortedAndSelected)
            }, onError: { error in
                if let _ = error as? ErrorResponseObject {
                    self.errorMsg.accept(TextContent.Errors.tagIndexError)
                }
            }).disposed(by: disposebag)
    }
    
    private func initializeSelectedTags(with tags: [Tag]) -> [Tag] {
        for item in tags {
            if let _ = self.contacts.value.first(where: {$0.id == item.id}) {
                item.selected = true
            }
        }
        
        return tags
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
        updateTagsToBeAddedOrRemoved()
    }
    
    func updateTagsToBeAddedOrRemoved() {
        let tags = contacts.value
        let existingTags = originalEvent?.tags ?? []
        let eventTags = self.eventTags.value
        
        for tag in tags {
            guard let id = tag.id else { return }
            if !existingTags.contains(where: {$0.id == id }) && !tagIdsToAdd.contains { $0 == id } {
                tagIdsToAdd.append(id)
            }
        }
        
        for tag in existingTags {
            guard let id = tag.id else { return }
            if !tags.contains(where: {$0.id == id }),
                let eventTag = eventTags.first(where: {$0.tagId == id}),
                let eventTagId = eventTag.id {
                eventTagsIdsToBeDeleted.append(eventTagId)
            }
        }
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
extension ViewEditEventViewModel {
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
        var addressString = ""
        if validateAddressFields() {
            let addressComponents = [address.value, city.value, state.value, zip.value]
            addressString = addressComponents.joined(separator: ", ")
        }

        return addressString
    }
}

