import XCTest
import RxTest
import RxSwift
import RxCocoa
import RxBlocking
@testable import Diwi

class EmailViewModelTests: XCTestCase {
    
    var emailViewModel: EmailViewModel!
    var scheduler: SchedulerType!
    
    override func setUp() {
        super.setUp()
        emailViewModel = EmailViewModel()
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    }
    
    override func tearDown() {
        super.setUp()
    }
    
    func testValidatesEmail_has_incorrect_format() {
        emailViewModel.data.accept("bad@email")
        let observable = emailViewModel.errorValue.asObservable().subscribeOn(scheduler)
        let emailValid = emailViewModel.validateCredentials()
        let result = try! observable.toBlocking().first()
        
        XCTAssertEqual(result, "Please enter a valid Email")
        XCTAssertFalse(emailValid)
        
    }
    
    func testValidatesEmail_has_correct_format() {
        emailViewModel.data.accept("good@email.com")
        let observable = emailViewModel.errorValue.asObservable().subscribeOn(scheduler)
        let emailValid = emailViewModel.validateCredentials()
        let result = try! observable.toBlocking().first()
        
        XCTAssertEqual(result, "")
        XCTAssertTrue(emailValid)
    }
}
