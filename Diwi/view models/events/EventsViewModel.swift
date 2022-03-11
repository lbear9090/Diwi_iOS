import Foundation
import RxCocoa
import RxSwift

struct EventsViewModel {
    
    let events          = BehaviorRelay<[Event]>(value: [])
    let tags            = BehaviorRelay<[Tag]>(value: [])
    let displayedTags   = BehaviorRelay<[Tag]>(value: [])
    let query           = BehaviorRelay<String>(value: "")
    let inputValue      = BehaviorRelay<String>(value: "")
    let navTitle        = BehaviorRelay<String>(value: "")
    let saveBtnText     = BehaviorRelay<String>(value: "")
    let disposebag      = DisposeBag()
    
    let isLoading       = BehaviorRelay<Bool>(value: false)
    let noMatchingEventsForPerson = BehaviorRelay<Bool>(value: false)
    let errorMsg        = BehaviorRelay<String>(value: "")
    let success         = BehaviorRelay<Bool>(value: false)
    let errorStatus     = BehaviorRelay<Int>(value: 0)
    
    private var itemsToBeDeleted: [Int] = []
    private let selectedEvents = BehaviorRelay<[Event]>(value: [])
    private let originalEventsArray = BehaviorRelay<[Event]>(value: [])
    
    private let eventService: EventInfoService
    let workflow: Workflow
    
    init(eventService: EventInfoService,
         selectedEvents: [Event],
         workflow: Workflow) {
        self.selectedEvents.accept(selectedEvents)
        self.eventService = eventService
        self.workflow = workflow
        setupBindings()
        getEvents()
        getTags()
        
        navTitle.accept(workflow.eventsViewNavTitle)
        saveBtnText.accept(workflow.eventsViewSaveBtnText)
    }
    
    private func setupBindings() {
        query.subscribe(onNext: { (value: String) in
                self.filterTags()
            }).disposed(by: disposebag)
    }
    
    func sortAlphabetically() {
        let events = self.events.value
        var eventsWithName = events.filter( { $0.name != "" && $0.name != nil })
        let eventsWithOutName = events.filter({ $0.name == nil || $0.name == "" })
        
        eventsWithName.sort { (a, b) -> Bool in
            return a.name! < b.name!
        }
        
        eventsWithName += eventsWithOutName
    
        self.events.accept(eventsWithName)
    }
    
    func sortByLatest() {
        var data = events.value
        data.sort { (a, b) -> Bool in
            guard let aDate = a.date else {
                return true
            }
            guard let bDate = b.date else {
                return false
            }
            return aDate > bDate
        }
        events.accept(data)
    }
    
    func sortByEarliest() {
        var data = events.value
        data.sort { (a, b) -> Bool in
            guard let aDate = a.date else {
                return false
            }
            guard let bDate = b.date else {
                return true
            }
            return aDate < bDate
        }
        events.accept(data)
    }
    
    func filterTags() {
        let text = query.value
        if text.count == 0 {
            displayedTags.accept(tags.value)
            return
        }
        
        let filtered = tags.value.filter { tag -> Bool in
            tag.title!.contains(text)
        }
        displayedTags.accept(filtered)
    }
    
    func getEvents() {
        eventService.index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.events.accept(response)
                self.originalEventsArray.accept(response)
            }, onError: { error in
                let errorObject = error as! ErrorResponseObject
                self.errorStatus.accept(errorObject.status)
            }).disposed(by: disposebag)
    }
    
    func getTags() {
        eventService.tags()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                let sorted = response.sorted(by: { (a, b) -> Bool in
                    a.title! < b.title!
                })
                self.tags.accept(sorted)
                self.displayedTags.accept(sorted)
            }, onError: { error in
                let errorObject = error as! ErrorResponseObject
                self.errorStatus.accept(errorObject.status)
            }).disposed(by: disposebag)
    }
    
    func searchEvents() {
        let ids = selectedTagIds()
        if (ids.count == 0) {
            return getEvents()
        }
        eventService.search(tagIds: ids)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                if response.count > 0 {
                    self.events.accept(response)
                } else {
                    self.noMatchingEventsForPerson.accept(true)
                    self.events.accept(self.originalEventsArray.value)
                }
            }, onError: { error in
                let errorObject = error as! ErrorResponseObject
                self.errorStatus.accept(errorObject.status)
            }).disposed(by: disposebag)
    }
    
    private func selectedTagIds() -> [Int] {
        return tags.value.filter({ tag -> Bool in tag.selected }).map({ tag -> Int in tag.id! })
    }
    
    func selectTag(withId: Int) {
        let new = tags.value.map { tag -> Tag in
            if (tag.id! == withId) {
                tag.selected = !tag.selected
            }
            return tag
        }
        tags.accept(new)
        filterTags()
    }
    
    func clearInputValue() {
        inputValue.accept("")
        query.accept("")
    }
    
    func setInputValue() {
        let value = tags.value
        let out = value.filter({ tag -> Bool in tag.selected }).map({ tag -> String in tag.title! }).joined(separator: ", ")
        inputValue.accept(out)
    }
    
    func eventAtIndex(_ index: Int) -> Event {
        return events.value[index]
    }
    
    func addToSelectedEvents(event: Event) {
        var events = selectedEvents.value
        if !events.contains(event) {
            events.append(event)
        }
        selectedEvents.accept(events)
    }

    func removeFromSelectedEvents(event: Event) {
        var events = selectedEvents.value
        if let index = events.firstIndex(where: {$0.id == event.id}) {
            events.remove(at: index)
            selectedEvents.accept(events)
        }
    }
    
    func getSelectedEvents() -> [Event] {
        print("selectedEvents count: \(selectedEvents.value.count)")
        return selectedEvents.value
    }
}

// MARK: - Removing events
extension EventsViewModel {
    mutating func addItemToBeDeleted(id: Int) {
        itemsToBeDeleted.append(id)
    }
    
    mutating func removeItemToBeDeleted(id: Int) {
        if let index = itemsToBeDeleted.firstIndex(of: id) {
            itemsToBeDeleted.remove(at: index)
        }
    }
    
    func removeItemsFromEvents() {
        for (index, id) in itemsToBeDeleted.enumerated() {
            isLoading.accept(true)
            eventService.delete(id: id)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { response in
                    if (index + 1) == self.itemsToBeDeleted.count {
                        self.isLoading.accept(false)
                        self.success.accept(true)
                    }
                }, onError: { error in
                    self.isLoading.accept(false)
                    guard let errorObject = error as? ErrorResponseObject else { return }
                    self.errorStatus.accept(errorObject.status)
                }).disposed(by: disposebag)
        }
    }
}
