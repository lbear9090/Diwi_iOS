import Foundation
import RxCocoa
import RxSwift

struct SignupViewModel {
    
    enum Field {
        case Email, Password, PasswordConfirm
    }
    
    let user: User = User()
    let disposebag = DisposeBag()
    
    let emailViewModel = EmailViewModel()
    let passwordViewModel = PasswordViewModel()
    let passwordConfirmViewModel = PasswordViewModel()
    //let usernameViewModel = UsernameViewModel()
    let termsViewModel = TermsViewModel()
    
    let success = BehaviorRelay<Bool>(value: false)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMsg = BehaviorRelay<String>(value: "")
    let passwordMatchError = BehaviorRelay<String>(value: "")
    let isFormValid = BehaviorRelay<Bool>(value: false)
    let termsText = BehaviorRelay<String>(value: "")
    
    private let userService: SignupService
    private let userInfoService: UserInfoService
    private let termsService: TermsService
    
    init(userService: SignupService,
         userInfoService: UserInfoService,
         termsService: TermsService) {
        self.userService = userService
        self.userInfoService = userInfoService
        self.termsService = termsService
        getTerms()
    }
    
    func validateFields() -> Bool {
        let passwords = passwordViewModel.validateCredentials() && passwordConfirmViewModel.validateCredentials()
        let passwordsMatch = passwordViewModel.data.value == passwordConfirmViewModel.data.value
        let passwordsOk = passwords && passwordsMatch
        return emailViewModel.validateCredentials() && termsViewModel.validateCredentials() && passwordsOk
    }
    
    func validateField(for field: Field){
        switch field {
        case .Email: let _ = emailViewModel.validateCredentials()
        case .Password: let _ = passwordViewModel.validateCredentials()
        case .PasswordConfirm: passwordMatchValidation()
        //case .Username: let _  = usernameViewModel.validateCredentials()
        }
    }
    
    func passwordMatchValidation() {
        if passwordViewModel.data.value != passwordConfirmViewModel.data.value {
            passwordMatchError.accept(TextContent.Errors.passwordsDoNotMatch)
        } else if passwordViewModel.data.value == passwordConfirmViewModel.data.value {
            passwordMatchError.accept(" ")
        }
    }
    
    func allFormFieldsHaveBeenFilledOut() -> Bool {
        return !emailViewModel.data.value.isEmpty &&
            !passwordViewModel.data.value.isEmpty &&
            !passwordConfirmViewModel.data.value.isEmpty
            //&& !usernameViewModel.data.value.isEmpty
    }
    
    func validateForm() {
        guard allFormFieldsHaveBeenFilledOut() else { return }
        
        if validateFields() {
            isFormValid.accept(true)
        } else {
            isFormValid.accept(false)
        }
    }
    
    func signup() {
        user.email = emailViewModel.data.value
        user.password = passwordViewModel.data.value
        user.passwordConfirmation = passwordConfirmViewModel.data.value
        user.profileType = "consumer"
        user.profile = Profile()
        user.profile?.userName = ""
        user.profile?.firstName = ""
        user.profile?.lastName = ""

        isLoading.accept(true)
        
        userService.signUp(with: user)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                if let jwt = response.jwt, let email = response.email {
                    self.userInfoService.setUserJWT(jwt: jwt)
                    self.userInfoService.setUserEmail(email: email)
                    //self.userInfoService.setUsername(username: response.profile!.userName!)
                    self.userInfoService.setUserId(id: String(response.id!))
                    self.userInfoService.setProfileId(id: String(response.profile!.id!))
                    self.userInfoService.setUserPassword(password: self.passwordViewModel.data.value)
                    self.acceptTerms(profile: response.profile!)
                }
            }, onError: { error in
                let errorObject = error as! ErrorResponseObject
                self.isLoading.accept(false)
                switch errorObject.status {
                case 400:
                    self.errorMsg.accept("Username/Email taken")
                case 500:
                    self.errorMsg.accept("There was an error processing your request")
                default:
                    self.errorMsg.accept("There was an error processing your request")
                }
            }).disposed(by: disposebag)
        
    }
    
    func acceptTerms(profile: Profile) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
        //2019-07-26 10:56:07 -0400
        let now = df.string(from: Date())
        let terms = Terms()
        terms.consumerId = profile.id
        terms.acceptedAt = now
        
        userService.acceptTerms(with: terms)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.isLoading.accept(false)
                self.success.accept(true)
            }, onError: { error in
                let errorObject = error as! ErrorResponseObject
                self.isLoading.accept(false)
                switch errorObject.status {
                case 400:
                    self.errorMsg.accept("Unable to create terms acceptance")
                case 401:
                    self.errorMsg.accept("Unauthroized")
                case 500:
                    self.errorMsg.accept("There was an error processing your request")
                default:
                    self.errorMsg.accept("There was an error processing your request")
                }
            }).disposed(by: disposebag)
    }
    
    func getTerms() {
        termsService.show()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                if let terms = response.terms {
                    self.termsText.accept(terms)
                }
            }).disposed(by: disposebag)
    }
}
