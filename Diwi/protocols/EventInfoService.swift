import Foundation
import RxSwift

protocol EventInfoService {
    func index() -> Observable<[Event]>
    func tags() -> Observable<[Tag]>
    func search(tagIds: [Int]) -> Observable<[Event]>
    func create(event: Event) -> Observable<Event>
    func show(id: Int) -> Observable<Event>
    func delete(id: Int) -> Observable<ApiResponseData>
    func edit(event: Event) -> Observable<Event>
}
