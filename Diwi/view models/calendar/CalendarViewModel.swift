import Foundation
import RxCocoa
import RxSwift

struct CalendarViewModel {
    let events          = BehaviorRelay<[Event]>(value: [])
    let viewingEvents   = BehaviorRelay<[Event]>(value: [])
    let viewingDate     = BehaviorRelay<Date>(value: Date())
    let navTitle        = BehaviorRelay<String>(value: "")
    let saveBtnText     = BehaviorRelay<String>(value: "")
    let disposebag      = DisposeBag()
    let previousSelectedDateForFriendCell = BehaviorRelay<CalendarCell>(value: CalendarCell())
    
    let success         = BehaviorRelay<Bool>(value: false)
    let errorStatus     = BehaviorRelay<Int>(value: 0)
    
    private let formatter = DateFormatter()
    private let selectedDateForFriend = BehaviorRelay<Date>(value: Date())
    private let eventService: EventInfoService
    let workflow: Workflow

    init(eventService: EventInfoService, workflow: Workflow) {
        self.eventService = eventService
        self.workflow = workflow
        
        navTitle.accept(workflow.chooseNewDateNavTitle)
        saveBtnText.accept(workflow.chooseNewDateSaveBtnText)
    }
    
    func filterEvents() {
        let filtered = events.value.filter { event -> Bool in
            return Calendar.current.compare(event.date!, to: viewingDate.value, toGranularity: .month) == .orderedSame
        }
        viewingEvents.accept(filtered)
    }
    
    func getEvent(on date: Date) -> Event? {
        let events = self.events.value
        
        guard events.count > 0 else { return nil }
        
        return events.first(where: { Calendar.current.compare(date,
                                                              to: $0.date!,
                                                              toGranularity: .day) == .orderedSame})
    }
    
    func getEvents() {
        eventService.index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                // ok to force unwrap optional, event always has a date
                let sorted = response.sorted {$0.date! > $1.date! }
                
                self.events.accept(sorted)
            }, onError: { error in
                let errorObject = error as! ErrorResponseObject
                self.errorStatus.accept(errorObject.status)
            }).disposed(by: disposebag)
    }
}

// MARK: - Conviencance Methods
extension CalendarViewModel {
    func getEventsCount() -> Int {
        return viewingEvents.value.count
    }
    
    func eventForIndex(indexPath: IndexPath) -> Event {
        return viewingEvents.value[indexPath.row]
    }
    
    func addSelectedDateForFriend(date: Date) {
        selectedDateForFriend.accept(date)
    }
    
    func getSelectedDateForFriend() -> Date {
        return selectedDateForFriend.value
    }
    
    func getPreviousSelectedCellForFriend() -> CalendarCell {
        return previousSelectedDateForFriendCell.value
    }
    
    func setPreviousSelectedCellForFriend(with cell: CalendarCell) {
        previousSelectedDateForFriendCell.accept(cell)
    }
}
