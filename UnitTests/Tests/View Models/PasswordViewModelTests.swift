import XCTest
import RxTest
import RxSwift
import RxCocoa
import RxBlocking
@testable import Diwi

class PasswordViewModelTests: XCTestCase {
    
    var passwordViewModel: PasswordViewModel!
    var scheduler: SchedulerType!
    
    override func setUp() {
        super.setUp()
        passwordViewModel = PasswordViewModel()
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    }
    
    override func tearDown() {
        super.setUp()
    }
    
    func testValidatesEmail_has_incorrect_length() {
        passwordViewModel.data.accept("passs")
        let observable = passwordViewModel.errorValue.asObservable().subscribeOn(scheduler)
        let emailValid = passwordViewModel.validateCredentials()
        let result = try! observable.toBlocking().first()
        
        XCTAssertEqual(result, "Password must be at leat 8 characters long")
        XCTAssertFalse(emailValid)
        
    }
    
    func testValidatesEmail_has_correct_format() {
        passwordViewModel.data.accept("good@email.com")
        let observable = passwordViewModel.errorValue.asObservable().subscribeOn(scheduler)
        let passwordValid = passwordViewModel.validateCredentials()
        let result = try! observable.toBlocking().first()
        
        XCTAssertEqual(result, "")
        XCTAssertTrue(passwordValid)
    }
}
