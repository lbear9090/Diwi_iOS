import UIKit
import RxSwift
import RxCocoa

class SignupController: UIViewController {
    // MARK: - view props
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    // MARK: - internal props
    weak var coordinator: MainCoordinator?
    let disposeBag = DisposeBag()
    var viewModel: SignupViewModel!
    var spinnerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinnerView = UIView.init(frame: view.bounds)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        viewModel = SignupViewModel(userService: UserService(),
                                    userInfoService: KeychainService(),
                                    termsService: TermsService())
        createViewModelBinding()       
        
    }
    
    private func goToHome() {
        coordinator?.start()
    }
}

// MARK: - Textfield delegate methods
extension SignupController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        viewModel.validateForm()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.validateForm()
        return true
    }
}

// MARK: - View model bindings
extension SignupController {
    private func createViewModelBinding() {
        // view prop bindings
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.emailViewModel.data)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel.data)
            .disposed(by: disposeBag)
        
        signupBtn.rx.tap.do(onNext: { [unowned self] in
            self.emailTextField.resignFirstResponder()
            self.passwordTextField.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            if self.viewModel.validateFields() {
                self.viewModel.signup()
            }
        }).disposed(by: disposeBag)
        
        loginBtn.rx.tap.bind {
            self.coordinator?.login()
        }.disposed(by: disposeBag)
        
        // view model bindings
        viewModel.emailViewModel.errorValue
            .asObservable()
            .bind(to: emailErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.passwordViewModel.errorValue
            .asObservable()
            .bind(to: passwordErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.success
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.removeSpinner(spinner: self.spinnerView)
                    // this is here soley for debugging purposes
                    self.presentMessage(title: "Success", message: "You are registered")
                    self.goToHome()
                }
            }).disposed(by: disposeBag)
        viewModel.errorMsg
            .subscribe(onNext: { [unowned self] (value) in
                if !value.isEmpty {
                    self.removeSpinner(spinner: self.spinnerView)
                    self.presentError(value)
                }
            }).disposed(by: disposeBag)
        
        viewModel.isFormValid
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.signupBtn.enabled()
                } else {
                    self.signupBtn.disabled()
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.displaySpinner(onView: self.view,
                                        spinnerView: self.spinnerView)
                }
            }).disposed(by: disposeBag)
    }
}
