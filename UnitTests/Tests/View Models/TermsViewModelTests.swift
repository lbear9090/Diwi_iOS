import XCTest
import RxTest
import RxSwift
import RxCocoa
import RxBlocking
@testable import Diwi

class TermsViewModelTests: XCTestCase {
    
    var termsViewModel: TermsViewModel!
    var scheduler: SchedulerType!
    
    override func setUp() {
        super.setUp()
        termsViewModel = TermsViewModel()
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    }
    
    override func tearDown() {
        super.setUp()
    }
    
    func testValidatesTerms_have_been_accepted() {
        termsViewModel.data.accept(true)
        let observable = termsViewModel.errorValue.asObservable().subscribeOn(scheduler)
        let termsValid = termsViewModel.validateCredentials()
        let result = try! observable.toBlocking().first()
        
        XCTAssertEqual(result, "")
        XCTAssertTrue(termsValid)
        
    }
    
    func testValidatesTerms_error_when_not_accepted() {
        termsViewModel.data.accept(false)
        let observable = termsViewModel.errorValue.asObservable().subscribeOn(scheduler)
        let termsValid = termsViewModel.validateCredentials()
        let result = try! observable.toBlocking().first()
        
        XCTAssertEqual(result, "Must accept terms and conditions")
        XCTAssertFalse(termsValid)
    }
}
