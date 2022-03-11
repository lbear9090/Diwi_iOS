import XCTest
import RxTest
import RxSwift
import RxCocoa
import RxBlocking
import KeychainSwift
@testable import Diwi

class SignupViewModelTests: XCTestCase {
    
    // Mock injected service
    private class MockUserService: SignupService {
        func acceptTerms(with terms: Terms) -> Observable<Terms> {
            return Observable.just(terms)
        }
        
        func signUp(with user: User) -> Observable<User> {
            user.jwt = "testJWT1234658686jfjskjhkadhjf"
            return Observable.just(user)
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
            return "testToken"
        }
    }
    
    var viewModel: SignupViewModel!
    var scheduler: SchedulerType!
    
    override func setUp() {
        super.setUp()
        let userService = MockUserService()
        let userInfoService = MockUserInfoService()
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        viewModel = SignupViewModel(userService: userService, userInfoService: userInfoService)
    }
    
    override func tearDown() {
        super.setUp()
    }
    
    func testValidatesForm_with_good_data() {
        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("password")
        viewModel.passwordConfirmViewModel.data.accept("password")
        viewModel.usernameViewModel.data.accept("guy")
        viewModel.termsViewModel.data.accept(true)
        
        let formValid = viewModel.validateFields()
        
        XCTAssertTrue(formValid)
    }
    
    func testValidatesForm_with_bad_email() {
        viewModel.emailViewModel.data.accept("test@testing")
        viewModel.passwordViewModel.data.accept("password")
        viewModel.passwordConfirmViewModel.data.accept("password")
        viewModel.usernameViewModel.data.accept("guy")
        viewModel.termsViewModel.data.accept(true)
        
        let formValid = viewModel.validateFields()
        
        XCTAssertFalse(formValid)
    }
    
    func testValidatesForm_with_bad_password() {
        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("pass")
        viewModel.passwordConfirmViewModel.data.accept("pass")
        viewModel.usernameViewModel.data.accept("guy")
        viewModel.termsViewModel.data.accept(true)
        
        let formValid = viewModel.validateFields()
        
        XCTAssertFalse(formValid)
    }
    
    func testValidatesForm_passwords_dont_match() {
        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("password")
        viewModel.passwordConfirmViewModel.data.accept("passwdakjsdhkas")
        viewModel.usernameViewModel.data.accept("guy")
        viewModel.termsViewModel.data.accept(true)
        
        let formValid = viewModel.validateFields()
        
        XCTAssertFalse(formValid)
    }
    
    func testValidatesForm_bad_username() {
        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("password")
        viewModel.passwordConfirmViewModel.data.accept("password")
        viewModel.usernameViewModel.data.accept("")
        viewModel.termsViewModel.data.accept(true)
        
        let formValid = viewModel.validateFields()
        
        XCTAssertFalse(formValid)
    }
    
    func testValidatesForm_terms_not_accepted() {
        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("password")
        viewModel.passwordConfirmViewModel.data.accept("password")
        viewModel.usernameViewModel.data.accept("guy")
        viewModel.termsViewModel.data.accept(false)
        
        let formValid = viewModel.validateFields()
        
        XCTAssertFalse(formValid)
    }
    
    func testSignup() {
        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("password")
        viewModel.passwordConfirmViewModel.data.accept("password")
        viewModel.usernameViewModel.data.accept("guy")
        viewModel.termsViewModel.data.accept(true)
        
        viewModel.signup()
        
        XCTAssertFalse(viewModel.success.value)
        XCTAssertTrue(viewModel.isLoading.value)
        XCTAssertEqual(viewModel.user.email, "test@testing.com")
        XCTAssertEqual(viewModel.user.password, "password")
        XCTAssertEqual(viewModel.user.profile?.userName, "guy")
    }
    
    func testAcceptTerms() {
        let profile = Profile()
        
        viewModel.acceptTerms(profile: profile)
        
        XCTAssertTrue(viewModel.success.value)
        XCTAssertFalse(viewModel.isLoading.value)
    }
    
    func testSignup_saves_jwt_to_keychain() {
        let keychain = KeychainSwift()

        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("password")

        viewModel.signup()

        if let jwt = keychain.get("jwt") {
            XCTAssertEqual(jwt, "testJWT1234658686jfjskjhkadhjf")
        }
    }
    
    func testSignup_saves_email_to_keychain() {
        let keychain = KeychainSwift()
        
        viewModel.emailViewModel.data.accept("test@testing.com")
        viewModel.passwordViewModel.data.accept("password")
        
        viewModel.signup()
        
        if let email = keychain.get("email") {
            XCTAssertEqual(email, "test@testing.com")
        }
    }
}
