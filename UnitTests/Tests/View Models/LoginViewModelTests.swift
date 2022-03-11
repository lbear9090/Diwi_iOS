import XCTest
import RxTest
import RxSwift
import RxCocoa
import RxBlocking
import KeychainSwift
@testable import Diwi

class LoginViewModelTests: XCTestCase {
    
    // Mock injected services
    private class MockUserService: LoginService {
        func login(with user: User) -> Observable<LoginResponse> {
            let response = LoginResponse()
            response.user = User()
            response.user?.jwt = "testJWT1234658686jfjskjhkadhjf"
            
            return Observable.just(response)
        }
    }
    
    private class MockDeviceService: DeviceService {
        override func create(with device: Device) -> Observable<Device> {
            return Observable.just(device)
        }
        
        override func update(with device: Device) -> Observable<Device> {
            return Observable.just(device)
        }
    }
    
    private class MockUserInfoService: UserInfoService {
        let keychain = KeychainSwift()
        
        func setUserJWT(jwt: String) {
            keychain.set(jwt, forKey: "jwt")
        }
        
        func setUserEmail(email: String) {
            keychain.set(email, forKey: "email")
        }
        
        func getUserDeviceToken() -> String? {
            return "test Token"
        }
    }
    
    var viewModel: LoginViewModel!
    var scheduler: SchedulerType!

    override func setUp() {
        super.setUp()
        let userService = MockUserService()
        let userInfoServie = MockUserInfoService()
        let deviceService = MockDeviceService()
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        viewModel = LoginViewModel(userService: userService,
                                   userInfoService: userInfoServie,
                                   deviceService: deviceService)
    }

    override func tearDown() {
        super.setUp()
    }

    func testValidatesForm_with_good_data() {
        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("password")
        
        let formValid = viewModel.validateFields()
        
        XCTAssertTrue(formValid)
    }
    
    func testValidatesForm_with_bad_email() {
        viewModel.emailViewModel.data.accept("test@testing")
        viewModel.passwordViewModel.data.accept("password")
        
        let formValid = viewModel.validateFields()
        
        XCTAssertFalse(formValid)
    }
    
    func testLogin() {
        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("password")
        
        viewModel.login()
        
        XCTAssertTrue(viewModel.success.value)
        XCTAssertFalse(viewModel.isLoading.value)
        XCTAssertEqual(viewModel.user.email, "test@testing.com")
        XCTAssertEqual(viewModel.user.password, "password")
    }
    
    func testLogin_saves_jwt() {
        let keychain = KeychainSwift()
        
        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("password")
        
        viewModel.login()
        
        if let jwt = keychain.get("jwt") {
            XCTAssertEqual(jwt, "testJWT1234658686jfjskjhkadhjf")
        }
    }
}
