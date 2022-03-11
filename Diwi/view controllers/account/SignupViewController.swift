import UIKit
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - view props
    let bg                      = UIImageView()
    let bgOverlay               = UIView()
    let navigationContainer     = UIView()
    let backButton              = UIButton()
    let navTitle                = UILabel()
    //let username                = MDCTextField()
    //var usernameController      = MDCTextInputControllerUnderline()
    let email                   = MDCTextField()
    var emailController         = MDCTextInputControllerUnderline()
    let password                = MDCTextField()
    var passwordController      = MDCTextInputControllerUnderline()
    let passwordConfirm         = MDCTextField()
    var passwordConfirmController = MDCTextInputControllerUnderline()
    let checkbox                = Checkbox()
    let terms                   = UILabel()
    let signupButton            = AppButton()
    let scrollContainer         = UIScrollView()
    let form                    = UIView()
    let viewTerms               = UIButton()
    var spinnerView             = UIView()
    //let usernameErrorLabel      = UILabel()
    let emailErrorLabel         = UILabel()
    let passwordErrorLabel      = UILabel()
    let passwordConfirmErrorLabel = UILabel()
    let termsContainer          = UIView()
    let termsText               = UITextView()
    let termsCloseButton        = UIButton()
    
    // MARK: - internal props
    weak var coordinator: MainCoordinator?
    var viewModel: SignupViewModel!
    let disposeBag = DisposeBag()
    
    var hasTopNotch: Bool {
        if #available(iOS 11.0,  *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SignupViewModel(userService: UserService(),
                                    userInfoService: KeychainService(),
                                    termsService: TermsService())
        createViewModelBinding()
        setupView()

        //goToOnboarding()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)

    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        self.dismiss(animated: true, completion: {
            self.startTabBar()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func goToLogin() {
        self.navigationController?.popViewController(animated: true)
//        coordinator?.popController()
    }
    
    @objc func toggleTerms() {
        checkbox.toggle()
        viewModel.termsViewModel.data.accept(checkbox.isChecked)
        viewModel.validateForm()
    }
    
    private func goToOnboarding() {
        startTabBar()
    }
    
    private func startTabBar() {
        let tabBarController = DiwiTabBarController()
        tabBarController.modalPresentationStyle = .currentContext
        self.navigationController?.present(tabBarController, animated: true, completion: nil)
    }
    
    private func startWithoutOnboarding() {
        self.dismiss(animated: true, completion: {
            self.startTabBar()
        })
    }
}

//MARK: - textfield delegate methods
extension SignupViewController {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        validateTextField(field: textField)
        viewModel.validateForm()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        validateTextField(field: textField)
        viewModel.validateForm()
        
        return true
    }
    
    private func validateTextField(field: UITextField) {
        if field == email {
            viewModel.validateField(for: .Email)
//        } else if field == username {
//            viewModel.validateField(for: .Username)
        } else if field == password {
            viewModel.validateField(for: .Password)
        } else if field == passwordConfirm {
            viewModel.validateField(for: .PasswordConfirm)
        }
    }
}

// MARK: - View model bindings
extension SignupViewController {
    private func createViewModelBinding() {
        email.rx.text.orEmpty
            .bind(to: viewModel.emailViewModel.data)
            .disposed(by: disposeBag)
        
        viewModel.emailViewModel
            .errorValue
            .asObservable()
            .bind(to: emailErrorLabel.rx.text)
            .disposed(by: disposeBag)

//        username.rx.text.orEmpty
//            .bind(to: viewModel.usernameViewModel.data)
//            .disposed(by: disposeBag)
//
//        viewModel.usernameViewModel
//            .errorValue
//            .asObservable()
//            .bind(to: usernameErrorLabel.rx.text)
//            .disposed(by: disposeBag)
        
        password.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel.data)
            .disposed(by: disposeBag)
        
        viewModel.passwordViewModel
            .errorValue
            .asObservable()
            .bind(to: passwordErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        passwordConfirm.rx.text.orEmpty
            .bind(to: viewModel.passwordConfirmViewModel.data)
            .disposed(by: disposeBag)
        
        viewModel.passwordMatchError
            .asObservable()
            .bind(to: passwordConfirmErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.termsViewModel.data.accept(checkbox.isChecked)
        
        signupButton.rx.tap.do(onNext: { [unowned self] in
            self.email.resignFirstResponder()
            self.password.resignFirstResponder()
            self.passwordConfirm.resignFirstResponder()
//            self.username.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            self.viewModel.signup()
        }).disposed(by: disposeBag)
        
        viewTerms.rx.tap.bind { [unowned self] in
            self.showTermsContainer()
        }.disposed(by: disposeBag)
        
        termsCloseButton.rx.tap.bind { [unowned self] in
            self.hideTermsContainer()
        }.disposed(by: disposeBag)
        
        viewModel.termsText
            .subscribe(onNext: { [unowned self] value in
                if !value.isEmpty {
                    self.termsText.text = value
                }
        }).disposed(by: disposeBag)
        
        viewModel.success
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    //self.startWithoutOnboarding()
                    self.goToOnboarding()
                }
            }).disposed(by: disposeBag)
        
        viewModel.errorMsg
            .subscribe(onNext: { [unowned self] (value) in
                if !value.isEmpty {
                    self.presentError(value)
                }
            }).disposed(by: disposeBag)
        
        viewModel.isFormValid
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.signupButton.enableButton()
                } else {
                    self.signupButton.disableButton()
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
                }
                else {
                    self.removeSpinner(spinner: self.spinnerView)
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Setup view
extension SignupViewController {
    private func setupView() {
        
        setupBg()
        setupBgOverlay()
        setupNav()
        setupForm()
//        setupUsername()
//        setupUsernameErrorLabel()
        setupEmail()
        setupEmailError()
        setupPassword()
        setupCheckbox()
        setupViewTerms()
        setupSpinner()
        setupButton()
        setupTermsContainer()

    }
    
    private func setupBg() {
        let image : UIImage = UIImage.Diwi.registrationBackground
        bg.image = image
        bg.contentMode = .scaleAspectFill
        bg.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bg)
        
        NSLayoutConstraint.activate([
            bg.leftAnchor.constraint(equalTo: view.leftAnchor),
            bg.rightAnchor.constraint(equalTo: view.rightAnchor),
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    private func setupBgOverlay() {
        bgOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        bgOverlay.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(bgOverlay)
        
        NSLayoutConstraint.activate([
            bgOverlay.leftAnchor.constraint(equalTo: bg.leftAnchor),
            bgOverlay.rightAnchor.constraint(equalTo: bg.rightAnchor),
            bgOverlay.topAnchor.constraint(equalTo: bg.topAnchor),
            bgOverlay.bottomAnchor.constraint(equalTo: bg.bottomAnchor)
            ])
    }
    
    private func setupNav() {
        navigationContainer.translatesAutoresizingMaskIntoConstraints = false
        navigationContainer.backgroundColor = UIColor.black
        view.addSubview(navigationContainer)
        
        var height: NSLayoutConstraint
        if (hasTopNotch) {
            height = navigationContainer.heightAnchor.constraint(equalToConstant: 90)
        }
        else {
            height = navigationContainer.heightAnchor.constraint(equalToConstant: 60)
        }
        
        NSLayoutConstraint.activate([
            navigationContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationContainer.topAnchor.constraint(equalTo: view.topAnchor),
            height
        ])
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage.Diwi.backIcon, for: .normal)
        backButton.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        navigationContainer.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: navigationContainer.bottomAnchor, constant: -10),
            backButton.leftAnchor.constraint(equalTo: navigationContainer.leftAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        navTitle.translatesAutoresizingMaskIntoConstraints = false
        navTitle.textColor = UIColor.white
        navTitle.text = TextContent.Buttons.createAccount
        navTitle.font = UIFont.Diwi.titleBold
        navigationContainer.addSubview(navTitle)
        
        NSLayoutConstraint.activate([
            navTitle.bottomAnchor.constraint(equalTo: navigationContainer.bottomAnchor, constant: -14),
            navTitle.centerXAnchor.constraint(equalTo: navigationContainer.centerXAnchor),
        ])
    }

    private func setupForm() {      
        form.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(form)

        NSLayoutConstraint.activate([
            form.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            form.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            form.leftAnchor.constraint(equalTo: view.leftAnchor),
            form.rightAnchor.constraint(equalTo: view.rightAnchor),
            form.heightAnchor.constraint(equalToConstant: 550)
        ])
    }

//    private func setupUsername() {
//        username.translatesAutoresizingMaskIntoConstraints = false
//        form.addSubview(username)
//        username.font? = UIFont.Diwi.textField
//        username.tag = 0
//        username.textColor = UIColor.white
//        username.autocapitalizationType = .none
//        username.autocorrectionType = .no
//        username.delegate = self
//        usernameController = MDCTextInputControllerUnderline(textInput: username)
//        usernameController.placeholderText = TextContent.Placeholders.username
//        usernameController.inlinePlaceholderColor = UIColor.white
//        usernameController.floatingPlaceholderNormalColor = UIColor.white
//        usernameController.floatingPlaceholderActiveColor = UIColor.white
//        usernameController.activeColor = UIColor.white
//
//        NSLayoutConstraint.activate([
//            username.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
//            username.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
//            username.topAnchor.constraint(equalTo: form.topAnchor)
//        ])
//    }
//
//    private func setupUsernameErrorLabel() {
//        usernameErrorLabel.translatesAutoresizingMaskIntoConstraints = false
//        usernameErrorLabel.font = UIFont.Diwi.address
//        usernameErrorLabel.textColor = .red
//
//        form.addSubview(usernameErrorLabel)
//
//        NSLayoutConstraint.activate([
//            usernameErrorLabel.heightAnchor.constraint(equalToConstant: 15),
//            usernameErrorLabel.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
//            usernameErrorLabel.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
//            usernameErrorLabel.topAnchor.constraint(equalTo: username.bottomAnchor)
//        ])
//    }
    
    
    private func setupEmail() {
        email.translatesAutoresizingMaskIntoConstraints = false
        form.addSubview(email)
        email.font? = UIFont.Diwi.textField
        email.tag = 1
        email.textColor = UIColor.white
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        email.keyboardType = .emailAddress
        email.delegate = self
        emailController = MDCTextInputControllerUnderline(textInput: email)
        emailController.textInputFont = UIFont.Diwi.textField
        emailController.inlinePlaceholderFont = UIFont.Diwi.textField
        emailController.placeholderText = TextContent.Placeholders.email
        emailController.inlinePlaceholderColor = UIColor.white
        emailController.floatingPlaceholderNormalColor = UIColor.white
        emailController.floatingPlaceholderActiveColor = UIColor.white
        emailController.activeColor = UIColor.white
        
        NSLayoutConstraint.activate([
            email.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
            email.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
            //email.topAnchor.constraint(equalTo: usernameErrorLabel.bottomAnchor)
            email.topAnchor.constraint(equalTo: form.topAnchor)
            ])
    }
    
    private func setupEmailError() {
        emailErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        emailErrorLabel.font = UIFont.Diwi.address
        emailErrorLabel.textColor = .red
        
        form.addSubview(emailErrorLabel)
        
        NSLayoutConstraint.activate([
            emailErrorLabel.heightAnchor.constraint(equalToConstant: 15),
            emailErrorLabel.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
            emailErrorLabel.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
            emailErrorLabel.topAnchor.constraint(equalTo: email.bottomAnchor)
        ])
    }

    private func setupPassword() {
        password.translatesAutoresizingMaskIntoConstraints = false
        form.addSubview(password)
        password.font? = UIFont.Diwi.textField
        password.tag = 2
        password.textColor = UIColor.white
        password.autocapitalizationType = .none
        password.autocorrectionType = .no
        password.isSecureTextEntry = true
        password.delegate = self
        passwordController = MDCTextInputControllerUnderline(textInput: password)
        passwordController.textInputFont = UIFont.Diwi.textField
        passwordController.inlinePlaceholderFont = UIFont.Diwi.textField
        passwordController.placeholderText = TextContent.Placeholders.password
        passwordController.inlinePlaceholderColor = UIColor.white
        passwordController.floatingPlaceholderNormalColor = UIColor.white
        passwordController.floatingPlaceholderActiveColor = UIColor.white
        passwordController.activeColor = UIColor.white

        NSLayoutConstraint.activate([
            password.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
            password.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
            password.topAnchor.constraint(equalTo: emailErrorLabel.bottomAnchor)
        ])
        
        passwordErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordErrorLabel.font = UIFont.Diwi.address
        passwordErrorLabel.textColor = .red
        
        form.addSubview(passwordErrorLabel)
        
        NSLayoutConstraint.activate([
            passwordErrorLabel.heightAnchor.constraint(equalToConstant: 15),
            passwordErrorLabel.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
            passwordErrorLabel.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
            passwordErrorLabel.topAnchor.constraint(equalTo: password.bottomAnchor)
        ])
        
        passwordConfirm.translatesAutoresizingMaskIntoConstraints = false
        form.addSubview(passwordConfirm)
        passwordConfirm.font? = UIFont.Diwi.textField
        passwordConfirm.tag = 3
        passwordConfirm.textColor = UIColor.white
        passwordConfirm.autocapitalizationType = .none
        passwordConfirm.autocorrectionType = .no
        passwordConfirm.isSecureTextEntry = true
        passwordConfirm.delegate = self
        passwordConfirmController = MDCTextInputControllerUnderline(textInput: passwordConfirm)
        passwordConfirmController.textInputFont = UIFont.Diwi.textField
        passwordConfirmController.inlinePlaceholderFont = UIFont.Diwi.textField
        passwordConfirmController.placeholderText = TextContent.Placeholders.passwordConfirm
        passwordConfirmController.inlinePlaceholderColor = UIColor.white
        passwordConfirmController.floatingPlaceholderNormalColor = UIColor.white
        passwordConfirmController.floatingPlaceholderActiveColor = UIColor.white
        passwordConfirmController.activeColor = UIColor.white
        
        NSLayoutConstraint.activate([
            passwordConfirm.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
            passwordConfirm.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
            passwordConfirm.topAnchor.constraint(equalTo: passwordErrorLabel.bottomAnchor)
            ])
        
        passwordConfirmErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordConfirmErrorLabel.font = UIFont.Diwi.address
        passwordConfirmErrorLabel.textColor = .red
        
        form.addSubview(passwordConfirmErrorLabel)
        
        NSLayoutConstraint.activate([
            passwordConfirmErrorLabel.heightAnchor.constraint(equalToConstant: 15),
            passwordConfirmErrorLabel.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
            passwordConfirmErrorLabel.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
            passwordConfirmErrorLabel.topAnchor.constraint(equalTo: passwordConfirm.bottomAnchor)
        ])
    }
    
    private func setupCheckbox() {
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.addTarget(self, action: #selector(toggleTerms), for: .touchUpInside)
        form.addSubview(checkbox)
        
        NSLayoutConstraint.activate([
            checkbox.topAnchor.constraint(equalTo: passwordConfirmErrorLabel.bottomAnchor, constant: 20),
            checkbox.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 40),
            checkbox.heightAnchor.constraint(equalToConstant: 18),
            checkbox.widthAnchor.constraint(equalToConstant: 18)
            ])
        
        
        terms.translatesAutoresizingMaskIntoConstraints = false
        terms.text = TextContent.Placeholders.agreeTerms
        terms.textColor = UIColor.white
        if UIDevice.deviceModel == "iPhone 5 or 5S or 5C" {
            terms.font = UIFont.Diwi.floatingButtonSmallScreen
        }
        else {
            terms.font = UIFont.Diwi.floatingButton
        }
        form.addSubview(terms)
        
        NSLayoutConstraint.activate([
            terms.leftAnchor.constraint(equalTo: checkbox.rightAnchor, constant: 5),
            terms.topAnchor.constraint(equalTo: passwordConfirmErrorLabel.bottomAnchor, constant: 21)
            ])
    }

    private func setupButton() {
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.setTitle(TextContent.Buttons.createAccount, for: .normal)
        signupButton.titleLabel?.font = UIFont.Diwi.button

        form.addSubview(signupButton)

        NSLayoutConstraint.activate([
            signupButton.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
            signupButton.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
            signupButton.topAnchor.constraint(equalTo: checkbox.bottomAnchor, constant: 40),
            signupButton.heightAnchor.constraint(equalToConstant: 50)
            ])
    }

    private func setupViewTerms() {
        viewTerms.translatesAutoresizingMaskIntoConstraints = false
        viewTerms.setTitle(TextContent.Placeholders.viewTerms, for: .normal)
        viewTerms.setTitleColor(UIColor.white, for: .normal)
        signupButton.titleLabel?.font = UIFont.Diwi.floatingButton
        viewTerms.titleLabel?.font = UIFont.Diwi.floatingButton
        
        view.addSubview(viewTerms)
        
        NSLayoutConstraint.activate([
            viewTerms.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -17),
            viewTerms.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
    
    private func setupTermsContainer() {
        termsContainer.translatesAutoresizingMaskIntoConstraints = false
        termsContainer.backgroundColor = .black
        termsContainer.layer.cornerRadius = 10
        termsContainer.layer.borderColor = UIColor.white.cgColor
        termsContainer.layer.borderWidth = 2
        
        termsText.translatesAutoresizingMaskIntoConstraints = false
        termsText.font = UIFont.Diwi.floatingButton
        termsText.textColor = .white
        termsText.textAlignment = .left
        termsText.backgroundColor = .black
        
        termsContainer.addSubview(termsText)
        
        NSLayoutConstraint.activate([
            termsText.topAnchor.constraint(equalTo: termsContainer.topAnchor, constant: 40),
            termsText.leftAnchor.constraint(equalTo: termsContainer.leftAnchor, constant: 40),
            termsText.rightAnchor.constraint(equalTo: termsContainer.rightAnchor, constant: -40),
            termsText.bottomAnchor.constraint(equalTo: termsContainer.bottomAnchor, constant: -40)
        ])
        
        termsCloseButton.translatesAutoresizingMaskIntoConstraints = false
        termsCloseButton.setImage(UIImage.Diwi.closeBtn, for: .normal)
        
        termsContainer.addSubview(termsCloseButton)
        
        NSLayoutConstraint.activate([
            termsCloseButton.topAnchor.constraint(equalTo: termsContainer.topAnchor, constant: 10),
            termsCloseButton.rightAnchor.constraint(equalTo: termsContainer.rightAnchor, constant: -10),
            termsCloseButton.heightAnchor.constraint(equalToConstant: 20),
            termsCloseButton.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func showTermsContainer() {
        view.addSubview(termsContainer)
        
        NSLayoutConstraint.activate([
            termsContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            termsContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            termsContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            termsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
    }
    
    func hideTermsContainer() {
        termsContainer.removeFromSuperview()
    }
    
    private func setupSpinner() {
        spinnerView = UIView.init(frame: view.bounds)
    }
}
