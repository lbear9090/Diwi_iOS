import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import RxSwift

class EventService: MainRequestService {
    
    func index() -> Observable<[Event]> {
        return newRequestWithKeyPathArrayResponse(route: EventRouter.index, keypath: "events")
    }
    
    func tags() -> Observable<[Tag]> {
        return newRequestWithKeyPathArrayResponse(route: EventRouter.tags, keypath: "tags")
    }
    
    func search(tagIds: [Int]) -> Observable<[Event]> {
        return newRequestWithKeyPathArrayResponse(route: EventRouter.search(tagIds), keypath: "events")
    }
    
    func create(event: Event) -> Observable<Event> {
        return newRequestWithKeyPath(route: EventRouter.create(event), keypath: "event")
    }
    
    func show(id: Int) -> Observable<Event> {
        return newRequestWithKeyPath(route: EventRouter.show(id), keypath: "event")
    }
    
    func delete(id: Int) -> Observable<ApiResponseData> {
        return newRequestWithKeyPath(route: EventRouter.delete(id), keypath: "event")
    }
    
    func edit(event: Event) -> Observable<Event> {
        return newRequestWithKeyPath(route: EventRouter.edit(event), keypath: "event")
    }
}

extension EventService: EventInfoService {}
