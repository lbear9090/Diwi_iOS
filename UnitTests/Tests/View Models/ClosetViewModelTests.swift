import XCTest
import RxTest
import RxSwift
import RxCocoa
import RxBlocking
import KeychainSwift
@testable import Diwi

class ClosetViewModelTests: XCTestCase {
    
    // Mock injected services
    private class MockClosetService: ClothingItemInfoService {
        func show(clothingItem: ClothingItem) -> Observable<ClothingItem> {
            return Observable.just(ClothingItem())
        }
        
        func index() -> Observable<[ClothingItem]> {
            let item = ClothingItem()
            let items = [item]
            
            return Observable.just(items)
        }
    }
    
    var viewModel: ClosetViewModel!
    var scheduler: SchedulerType!
    
    override func setUp() {
        super.setUp()
        let closetService = MockClosetService()
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        viewModel = ClosetViewModel(clothingItemService: closetService)
        
    }
    
    override func tearDown() {
        super.setUp()
    }
    
    func testGetCloset() {
        XCTAssertTrue(viewModel.clothingItems.value.count  == 0)
        viewModel.getCloset()
        XCTAssertTrue(viewModel.clothingItems.value.count  > 0)
    }
}
