import UIKit
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

final class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - view props
    let navigationContainer         = UIView()
    let backButton                  = UIButton()
    let navTitle                    = UILabel()
    let logout                      = UIButton()
    let saveButton                  = AppButton()
    let cancelButton                = AppButton()
    let buttonsContainer            = UIStackView()
    let editButton                  = AppButton()
    let username                    = MDCTextField()
    var usernameController          = MDCTextInputControllerUnderline()
    let email                       = MDCTextField()
    var emailController             = MDCTextInputControllerUnderline()
    let password                    = MDCTextField()
    var passwordController          = MDCTextInputControllerUnderline()
    let confirmPassword             = MDCTextField()
    var confirmPasswordController   = MDCTextInputControllerUnderline()
    var spinnerView                 = UIView()
    let textFieldCover              = UIView()
    var scrollView                  = UIScrollView()
    let contentView                 = UIView()
    var scrollContainerBottomConstraint: NSLayoutConstraint?
    var navigationBarAppearace = UINavigationBar.appearance()
    
    // MARK: - internal props
    let disposeBag = DisposeBag()
    var viewModel: ProfileViewModel!
    var textFields: [MDCTextField] = []
    var textFieldControllers: [MDCTextInputControllerUnderline] = []
    var textFieldPlaceHolders: [String] = [TextContent.Placeholders.email,
                                           TextContent.Placeholders.passwordConfirm,
                                           TextContent.Placeholders.password,
                                           TextContent.Placeholders.username]
    let emptyPlaceholder = ""
    var logoutTopAnchor: NSLayoutConstraint = NSLayoutConstraint()
    let screenWidth = UIScreen.main.bounds.width
    var goTologout: (() -> Void)?
    var goBack: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViewModelBinding()
        setupView()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    func setupNavBar() {
        navigationItem.title = "Account"
        
        navigationController?.navigationBar.backgroundColor = UIColor.Diwi.azure
        navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    private func enableEditingMode() {
        editButton.fadeOut()
        logout.isHidden = true
        showButtonsContainer()
        addAllPlaceHolders()
        hideTextFieldCover()
    }
    
    private func disableEditingMode() {
        hideButtonsContainer()
        logout.isHidden = false
        editButton.fadeIn()
        removeAllPlaceholders()
        showTextFieldCover()
    }
    
    private func addAllPlaceHolders() {
        for (index, field) in textFieldControllers.enumerated() {
            field.placeholderText = textFieldPlaceHolders[index]
        }
    }
    
    private func removeAllPlaceholders() {
        for field in textFieldControllers {
            field.placeholderText = emptyPlaceholder
        }
    }
}


// MARK: - View model bindings
extension ProfileViewController {
    private func createViewModelBinding() {
        // MARK: - view model bindings
        viewModel.email
            .asObservable()
            .map { $0 }
            .bind(to:self.email.rx.text)
            .disposed(by:self.disposeBag)
        
        viewModel.username
            .asObservable()
            .map { $0 }
            .bind(to:self.username.rx.text)
            .disposed(by:self.disposeBag)
        
        viewModel.password
            .asObservable()
            .map { $0 }
            .bind(to:self.password.rx.text)
            .disposed(by:self.disposeBag)
        
        email.rx.text.orEmpty
            .bind(to: viewModel.emailViewModel.data)
            .disposed(by: disposeBag)

        username.rx.text.orEmpty
            .bind(to: viewModel.usernameViewModel.data)
            .disposed(by: disposeBag)

        password.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel.data)
            .disposed(by: disposeBag)

        confirmPassword.rx.text.orEmpty
            .bind(to: viewModel.passwordConfirmViewModel.data)
            .disposed(by: disposeBag)
        
        viewModel.success.drive(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.goBack?()
                }
            }).disposed(by: disposeBag)
        
        viewModel.errorMessage
            .drive(onNext: { [unowned self] (value) in
                if !value.isEmpty {
                    self.presentError(value)
                }
            }).disposed(by: disposeBag)
        
        viewModel.formChanged
            .drive(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.saveButton.enableButton()
                } else {
                    self.saveButton.disableButton()
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
                }
                else {
                    self.removeSpinner(spinner: self.spinnerView)
                }
            }).disposed(by: disposeBag)
        
        // MARK: - Button Bindings
        logout.rx.tap.bind { [unowned self] in
            self.logout.buttonPressedAnimation {
                self.goTologout?()
            }
        }.disposed(by: disposeBag)
        
        backButton.rx.tap.bind { [unowned self] in
            self.goBack?()
        }.disposed(by: disposeBag)
        
        editButton.rx.tap.bind { [unowned self] in
            self.editButton.buttonPressedAnimation {
                self.enableEditingMode()
            }
        }.disposed(by: disposeBag)
        
        cancelButton.rx.tap.bind {  [unowned self] in
            self.disableEditingMode()
        }.disposed(by: disposeBag)
        
        saveButton.rx.tap.bind { [unowned self] in
            self.viewModel.update()
        }.disposed(by: disposeBag)
    }
}

// MARK: - Setup view
extension ProfileViewController {
    private func setupView() {
        view.backgroundColor = UIColor.white
        setupNav()
//        setupScrollView()
//        setupContentView()
        setupUsername()
        setupEmail()
        setupPassword()
        setupSpinner()
        setupEditButton()
        setupButtonContainer()
        setupConfirmPassword()
        setupSaveButton()
        setupCancelButton()
        setupLogout()
        commonTextFieldSetup()
        setupTextFieldCover()
    }
    
    private func setupNav() {
        navigationContainer.translatesAutoresizingMaskIntoConstraints = false
        navigationContainer.backgroundColor = UIColor.black
        view.addSubview(navigationContainer)
        
        var height: NSLayoutConstraint
        if hasNotch() {
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
        backButton.setImage(UIImage.Diwi.backIconWhite, for: .normal)
        navigationContainer.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: navigationContainer.bottomAnchor, constant: -10),
            backButton.leftAnchor.constraint(equalTo: navigationContainer.leftAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28)
            ])
        
        navTitle.translatesAutoresizingMaskIntoConstraints = false
        navTitle.textColor = UIColor.white
        navTitle.text = TextContent.Labels.profile
        navTitle.font = UIFont.Diwi.titleBold
        navigationContainer.addSubview(navTitle)
        
        NSLayoutConstraint.activate([
            navTitle.bottomAnchor.constraint(equalTo: navigationContainer.bottomAnchor, constant: -14),
            navTitle.centerXAnchor.constraint(equalTo: navigationContainer.centerXAnchor),
            ])
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.frame.size.height
                                                     ))
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.Diwi.yellow
        scrollView.keyboardDismissMode = .onDrag
        
        view.addSubview(scrollView)
        
        scrollContainerBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationContainer.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 2000)
//            scrollContainerBottomConstraint!
        ])
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .red
        let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightConstraint.priority = UILayoutPriority(250) //very important
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            heightConstraint,
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.height)
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 2000)
        ])

    }
    
    private func setupUsername() {
        username.translatesAutoresizingMaskIntoConstraints = false
        usernameController = MDCTextInputControllerUnderline(textInput: username)
        
        view.addSubview(username)
        NSLayoutConstraint.activate([
            username.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            username.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            username.topAnchor.constraint(equalTo: navigationContainer.bottomAnchor, constant: 35)
            ])

    }
    
    private func setupEmail() {
        email.translatesAutoresizingMaskIntoConstraints = false
        email.isHidden = false
        email.keyboardType = .emailAddress
        emailController = MDCTextInputControllerUnderline(textInput: email)
        
        view.addSubview(email)
        NSLayoutConstraint.activate([
            email.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            email.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            email.topAnchor.constraint(equalTo: username.bottomAnchor)
            ])


    }
    
    private func setupPassword() {
        password.translatesAutoresizingMaskIntoConstraints = false
        password.isSecureTextEntry = true
        passwordController = MDCTextInputControllerUnderline(textInput: password)
        
        view.addSubview(password)
        NSLayoutConstraint.activate([
            password.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            password.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            password.topAnchor.constraint(equalTo: email.bottomAnchor)
        ])

    }
    
    private func setupConfirmPassword() {
        confirmPassword.translatesAutoresizingMaskIntoConstraints = false
        confirmPassword.isHidden = true
        confirmPassword.isSecureTextEntry = true
        confirmPasswordController = MDCTextInputControllerUnderline(textInput: confirmPassword)

        buttonsContainer.addArrangedSubview(confirmPassword)
                
        NSLayoutConstraint.activate([
            confirmPassword.widthAnchor.constraint(equalToConstant: (screenWidth - 60))
        ])
    }
    
    private func commonTextFieldSetup() {
        textFields = [email, confirmPassword, password, username]
        textFieldControllers = [emailController, confirmPasswordController, passwordController, usernameController]
        
        for field in textFields {
            field.translatesAutoresizingMaskIntoConstraints = false
            field.font? = UIFont.Diwi.textField
            field.textColor = .black
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.delegate = self
        }
        
        for controller in textFieldControllers {
            controller.inlinePlaceholderColor = UIColor.Diwi.darkGray
            controller.floatingPlaceholderNormalColor = UIColor.Diwi.darkGray
            controller.floatingPlaceholderActiveColor = UIColor.Diwi.darkGray
            controller.activeColor = UIColor.Diwi.azure
            controller.normalColor = UIColor.Diwi.azure
            controller.underlineViewMode = .always
        }
    }
    
    private func setupLogout() {
        logout.translatesAutoresizingMaskIntoConstraints = false
        logout.setTitle(TextContent.Buttons.logout, for: .normal)
        logout.setTitleColor(UIColor.Diwi.azure, for: .normal)
        logout.titleLabel?.font = UIFont.Diwi.floatingButton
        
        view.addSubview(logout)
        logoutTopAnchor = logout.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 14)
        
        NSLayoutConstraint.activate([
            logout.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutTopAnchor
            ])

    }
    
    private func setupSpinner() {
        spinnerView = UIView.init(frame: view.bounds)
    }
    
    private func setupEditButton() {
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle(TextContent.Buttons.editProfile, for: .normal)
        editButton.titleLabel?.font = UIFont.Diwi.button
        editButton.setTitleColor(.white, for: .normal)
        
        view.addSubview(editButton)
        NSLayoutConstraint.activate([
            editButton.heightAnchor.constraint(equalToConstant: 50),
            editButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            editButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -67),
            editButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
        ])

    }
    
    private func setupButtonContainer() {
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.axis = .vertical
        buttonsContainer.alignment = .center
        buttonsContainer.spacing = 10
        
        view.addSubview(buttonsContainer)
        NSLayoutConstraint.activate([
            buttonsContainer.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 0),
            buttonsContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            buttonsContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
        ])

        
    }
    
    private func setupSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle(TextContent.Labels.saveProfile, for: .normal)
        saveButton.titleLabel?.font = UIFont.Diwi.button
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.isHidden = true
        saveButton.disableButton()
        
        buttonsContainer.addArrangedSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.widthAnchor.constraint(equalToConstant: (screenWidth - 60)),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.inverseColor()
        cancelButton.setTitle(TextContent.Labels.cancel, for: .normal)
        cancelButton.titleLabel?.font = UIFont.Diwi.button
        cancelButton.setTitleColor(UIColor.Diwi.barney, for: .normal)
        cancelButton.isHidden = true
        
        buttonsContainer.addArrangedSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: (screenWidth - 60)),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupTextFieldCover() {
        textFieldCover.translatesAutoresizingMaskIntoConstraints = false
        textFieldCover.backgroundColor = .clear
        
        showTextFieldCover()
    }
    
    private func hideButtonsContainer() {
        for view in buttonsContainer.arrangedSubviews {
            view.isHidden = true
        }
    }
    
    private func showButtonsContainer() {
        for view in buttonsContainer.arrangedSubviews {
            view.isHidden = false
        }
    }
    
    private func hideTextFieldCover() {
        textFieldCover.removeFromSuperview()
    }
    
    private func showTextFieldCover() {
        view.addSubview(textFieldCover)
        textFieldCoverContraints()
    }
    
    private func textFieldCoverContraints() {
        NSLayoutConstraint.activate([
            textFieldCover.leftAnchor.constraint(equalTo: view.leftAnchor),
            textFieldCover.rightAnchor.constraint(equalTo: view.rightAnchor),
            textFieldCover.topAnchor.constraint(equalTo: navigationContainer.bottomAnchor),
            textFieldCover.bottomAnchor.constraint(equalTo: password.bottomAnchor, constant: 10)
        ])
    }
}

//MARK: - textfield delegate methods
extension ProfileViewController {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        viewModel.validateForm()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.validateForm()
        
        return true
    }
}
