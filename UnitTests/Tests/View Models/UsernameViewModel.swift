import XCTest
import RxTest
import RxSwift
import RxCocoa
import RxBlocking
@testable import Diwi

class UsernameViewModelTests: XCTestCase {
    
    var usernameViewModel: UsernameViewModel!
    var scheduler: SchedulerType!
    
    override func setUp() {
        super.setUp()
        usernameViewModel = UsernameViewModel()
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    }
    
    override func tearDown() {
        super.setUp()
    }
    
    func testValidatesUsername_not_empty() {
        usernameViewModel.data.accept("")
        let observable = usernameViewModel.errorValue.asObservable().subscribeOn(scheduler)
        let usernameValid = usernameViewModel.validateCredentials()
        let result = try! observable.toBlocking().first()
        
        XCTAssertEqual(result, "Username cannot be empty")
        XCTAssertFalse(usernameValid)
        
    }
    
    func testValidatesUsername_has_correct_format() {
        usernameViewModel.data.accept("cooldude")
        let observable = usernameViewModel.errorValue.asObservable().subscribeOn(scheduler)
        let usernameValid = usernameViewModel.validateCredentials()
        let result = try! observable.toBlocking().first()
        
        XCTAssertEqual(result, "")
        XCTAssertTrue(usernameValid)
    }
}
