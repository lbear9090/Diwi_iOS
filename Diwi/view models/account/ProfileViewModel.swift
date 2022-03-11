import Foundation
import RxCocoa
import RxSwift

struct ProfileViewModel {
    
    enum FieldTypes {
        case email, username, password
    }
    
    let email                       = BehaviorRelay<String?>(value: "")
    let username                    = BehaviorRelay<String?>(value: "")
    let password                    = BehaviorRelay<String?>(value: "")
    let confirmPassword             = BehaviorRelay<String?>(value: "")
    
    var success: Driver<Bool> { return _success.asDriver() }
    var isLoading: Driver<Bool> { return _isLoading.asDriver() }
    var errorMessage: Driver<String> { return _errorMessage.asDriver() }
    var formChanged: Driver<Bool> { return _formChanged.asDriver() }
    
    private let _success             = BehaviorRelay<Bool>(value: false)
    private let _errorMessage       = BehaviorRelay<String>(value: "")
    private let _isLoading          = BehaviorRelay<Bool>(value: false)
    private let _formChanged        = BehaviorRelay<Bool>(value: false)
    
    let emailViewModel = EmailViewModel()
    let passwordViewModel = PasswordViewModel()
    let passwordConfirmViewModel = PasswordViewModel()
    let usernameViewModel = UsernameViewModel()
    
    private let userInfoService: UserInfoService
    private let updateUserService: UpdateUserService
    
    let disposebag = DisposeBag()
    
    init(userInfoService: UserInfoService, updateUserService: UpdateUserService) {
        self.userInfoService = userInfoService
        self.updateUserService = updateUserService
        self.populateView()
    }
    
    private func populateView() {
        if let currentPassword = userInfoService.getUserPassword() {
            self.password.accept(currentPassword)
            
        }
        
        if let currentEmail = userInfoService.getUserEmail() {
            self.email.accept(currentEmail)
        }
        
        if let currentUsername = userInfoService.getUsername() {
            self.username.accept(currentUsername)
        }
    }
    
    func validateFields() -> Bool {
        return emailViewModel.validateCredentials() &&
               usernameViewModel.validateCredentials() &&
               shouldValidatePasswords() ? validatePasswords() : true
    }
    
    private func shouldValidatePasswords() -> Bool {
        guard passwordConfirmViewModel.data.value.isEmpty else { return true }
        
        return false
    }
    
    func validateForm() {
        if validateFields() {
            _formChanged.accept(true)
        } else {
            _formChanged.accept(false)
        }
    }
    
    private func validatePasswords() -> Bool {
        guard passwordViewModel.validateCredentials() && passwordConfirmViewModel.validateCredentials() else { return false }
        
        return  passwordViewModel.data.value == passwordConfirmViewModel.data.value
    }
}

//  MARK: - API logic
extension ProfileViewModel {
    func update() {
        let user = buildUserObject()
        print(user)
        _isLoading.accept(true)
        
        updateUserService
            .update(with: user)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.updateUserInfoinKeychain()
                self._isLoading.accept(false)
                self._success.accept(true)
            }, onError: { error in
                self._isLoading.accept(false)
                self._errorMessage.accept("There was an error processing your request")
            }).disposed(by: disposebag)
    }
    
    private func updateUserInfoinKeychain() {
        userInfoService.setUserEmail(email: emailViewModel.data.value)
        //userInfoService.setUsername(username: usernameViewModel.data.value)
        userInfoService.setUserPassword(password: passwordViewModel.data.value)
        
    }
    
    private func fieldHasChanged(value: String, fieldType: FieldTypes) -> Bool {
        switch fieldType {
        case .email:
            guard let currentEmail = userInfoService.getUserEmail(),
                currentEmail == value else { return true }
            
            return false
        case .username:
            guard let currentUsername = userInfoService.getUsername(),
                currentUsername == value else { return true }
            
            return false
        case .password:
            guard let currentPassword = userInfoService.getUserPassword(),
                currentPassword == value else { return true }
            
            return false
        }
    }
    
    private func buildUserObject() -> User {
        let user = User()
        
        if let id = userInfoService.getUserId() {
            user.id = Int(id)
        }
        
        
        if fieldHasChanged(value: emailViewModel.data.value, fieldType: .email) {
            user.email = emailViewModel.data.value
        }
        
        if fieldHasChanged(value: usernameViewModel.data.value, fieldType: .username) {
            user.profile?.userName = usernameViewModel.data.value
        }
        
        if fieldHasChanged(value: passwordViewModel.data.value, fieldType: .password) {
            user.password = passwordViewModel.data.value
            user.passwordConfirmation = passwordViewModel.data.value
        }
        
        return user
    }
}
