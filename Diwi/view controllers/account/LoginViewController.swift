import UIKit
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - view props
    let bg = UIImageView()
    let bgOverlay = UIView()
    let logo = UIImageView()
    let email = MDCTextField()
    var emailController = MDCTextInputControllerUnderline()
    let password = MDCTextField()
    var passwordController = MDCTextInputControllerUnderline()
    let loginButton = AppButton()
    let forgotPassword = UIButton()
    let signup = UIButton()
    let form = UIView()
    var spinnerView = UIView()
    
    // MARK: - internal props
    weak var coordinator: MainCoordinator?
    var viewModel: LoginViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginViewModel(userService: UserService(),
                                   userInfoService: KeychainService(),
                                   deviceService: DeviceService())
        createViewModelBinding()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        clearForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func goToSignup() {
        let vc = SignupViewController()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func startTabBar() {
        let tabBarController = DiwiTabBarController()
        tabBarController.modalPresentationStyle = .currentContext
        self.navigationController?.present(tabBarController, animated: true, completion: nil)
    }
    
    private func goToHomePage() {
        coordinator?.homePage()
    }
    
    private func clearForm() {
        email.text = ""
        password.text = ""
        email.text = ""
        password.text = ""
        //        viewModel.validateForm()
        //        self.startTabBar()
    }
}

//MARK: - textfield delegate methods
extension LoginViewController {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        viewModel.validateForm()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.validateForm()
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

//MARK: - view model bindings
extension LoginViewController {
    private func createViewModelBinding() {
        
        email.rx.text.orEmpty
            .bind(to: viewModel.emailViewModel.data)
            .disposed(by: disposeBag)
        
        password.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel.data)
            .disposed(by: disposeBag)
        
        forgotPassword.rx.tap.bind { [unowned self] in
            self.forgotPasswordButton()
        }.disposed(by: disposeBag)
        
        loginButton.rx.tap.do(onNext: { [unowned self] in
            self.email.resignFirstResponder()
            self.password.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            self.viewModel.login()
        }).disposed(by: disposeBag)
        
        viewModel.success
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    //self.goToHomePage()
                    self.startTabBar()
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
//                if value {
                    self.loginButton.enableButton()
//                } else {
//                    self.loginButton.disableButton()
//                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
                } else {
                    self.removeSpinner(spinner: self.spinnerView)
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Setup view
extension LoginViewController {
    private func setupView() {
        setupBg()
        setupBgOverlay()
        setupLogo()
        setupForm()
        setupEmail()
        setupPassword()
        setupButton()
        setupForgotPassword()
        setupSignup()
        setupSpinner()
    }
    
    private func setupBg() {
        let image : UIImage = UIImage.Diwi.homepageBackground
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
    
    private func setupLogo() {
        let image : UIImage = UIImage.Diwi.logo1
        logo.image = image
        logo.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logo)
        
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.widthAnchor.constraint(equalToConstant: 122),
            logo.heightAnchor.constraint(equalToConstant: 61)
        ])
    }
    
    private func setupForm() {
        form.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(form)
        
        NSLayoutConstraint.activate([
            form.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            form.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            form.heightAnchor.constraint(equalToConstant: 250),
            form.leftAnchor.constraint(equalTo: view.leftAnchor),
            form.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func setupEmail() {
        email.translatesAutoresizingMaskIntoConstraints = false
        form.addSubview(email)
        
        email.font? = UIFont.Diwi.textField
        email.tag = 0
        email.textColor = UIColor.white
        email.keyboardType = .emailAddress
        email.autocorrectionType = .no
        email.autocapitalizationType = .none
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
            email.topAnchor.constraint(equalTo: form.topAnchor)
        ])
    }
    
    private func setupPassword() {
        password.translatesAutoresizingMaskIntoConstraints = false
        form.addSubview(password)
        
        password.font? = UIFont.Diwi.textField
        password.tag = 1
        password.textColor = UIColor.white
        password.isSecureTextEntry = true
        password.autocapitalizationType = .none
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
            password.topAnchor.constraint(equalTo: email.bottomAnchor)
        ])
    }
    
    private func setupButton() {
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle(TextContent.Buttons.login, for: .normal)
        loginButton.titleLabel?.font = UIFont.Diwi.button
        form.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
            loginButton.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
            loginButton.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 20),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupForgotPassword() {
        forgotPassword.translatesAutoresizingMaskIntoConstraints = false
        forgotPassword.setTitle(TextContent.Buttons.forgotPassword, for: .normal)
        forgotPassword.titleLabel?.font = UIFont.Diwi.floatingButton
        view.addSubview(forgotPassword)
        
        NSLayoutConstraint.activate([
            forgotPassword.centerXAnchor.constraint(equalTo: form.centerXAnchor),
            forgotPassword.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12)
        ])
    }
    
    private func setupSignup() {
        signup.translatesAutoresizingMaskIntoConstraints = false
        signup.setTitle(TextContent.Buttons.dontHaveAccount, for: .normal)
        signup.titleLabel?.font = UIFont.Diwi.floatingButton
        signup.addTarget(self, action: #selector(goToSignup), for: .touchUpInside)
        view.addSubview(signup)
        
        NSLayoutConstraint.activate([
            signup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signup.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -17)
        ])
    }
    
    private func setupSpinner() {
        spinnerView = UIView.init(frame: view.bounds)
    }
    
    func forgotPasswordButton() {
        let vc = ForgotPasswordViewController()
        let vm = ForgotPasswordViewModel(userService: UserService())
        vc.viewModel = vm
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
