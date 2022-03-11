import UIKit
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - view props
    let bg = UIImageView()
    let bgOverlay = UIView()
    let logo = UIImageView()
    let email = MDCTextField()
    var emailController = MDCTextInputControllerUnderline()
    let sendButton = AppButton()
    let login = UIButton()
    let signup = UIButton()
    let form = UIView()
    var spinnerView = UIView()
    let navTitle = UILabel()
    
    // MARK: - internal props
    var viewModel: ForgotPasswordViewModel!
    let disposeBag = DisposeBag()
    var goToSignup: (() -> Void)?
    var goToLogin: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        createViewModelBinding()
        setupView()
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
}

//MARK: - textfield delegate methods
extension ForgotPasswordViewController {
    
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
extension ForgotPasswordViewController {
    private func createViewModelBinding() {
        
        email.rx.text.orEmpty
            .bind(to: viewModel.emailViewModel.data)
            .disposed(by: disposeBag)
        
        login.rx.tap.bind { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        signup.rx.tap.bind { [unowned self] in
            self.signupCall()
        }.disposed(by: disposeBag)
        
        sendButton.rx.tap.bind { [unowned self] in
            self.viewModel.forgotPassword()
        }.disposed(by: disposeBag)
        
        viewModel.success
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.goToLogin?()
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
                    self.sendButton.enableButton()
                } else {
                    self.sendButton.disableButton()
                }
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
    func signupCall() {
        let vc = SignupViewController()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Setup view
extension ForgotPasswordViewController {
    private func setupView() {
        setupBg()
        setupBgOverlay()
        setupTitle()
        setupForm()
        setupEmail()
        setupButton()
        setupLogin()
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
    
    private func setupTitle() {
        navTitle.translatesAutoresizingMaskIntoConstraints = false
        navTitle.textColor = UIColor.white
        navTitle.text = TextContent.Labels.forgotPassword
        navTitle.font = UIFont.Diwi.titleBold
        
        view.addSubview(navTitle)
        
        NSLayoutConstraint.activate([
            navTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            navTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
    
    private func setupButton() {
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle(TextContent.Buttons.sendEmail, for: .normal)
        sendButton.titleLabel?.font = UIFont.Diwi.button
        
        form.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            sendButton.leftAnchor.constraint(equalTo: form.leftAnchor, constant: 30),
            sendButton.rightAnchor.constraint(equalTo: form.rightAnchor, constant: -30),
            sendButton.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 20),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupLogin() {
        login.translatesAutoresizingMaskIntoConstraints = false
        login.setTitle(TextContent.Buttons.login, for: .normal)
        login.titleLabel?.font = UIFont.Diwi.floatingButton
        
        view.addSubview(login)
        
        NSLayoutConstraint.activate([
            login.centerXAnchor.constraint(equalTo: form.centerXAnchor),
            login.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12)
        ])
    }
    
    private func setupSignup() {
        signup.translatesAutoresizingMaskIntoConstraints = false
        signup.setTitle(TextContent.Buttons.dontHaveAccount, for: .normal)
        signup.titleLabel?.font = UIFont.Diwi.floatingButton
        
        view.addSubview(signup)
        
        NSLayoutConstraint.activate([
            signup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signup.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -17)
        ])
    }
    
    private func setupSpinner() {
        spinnerView = UIView.init(frame: view.bounds)
    }
}
