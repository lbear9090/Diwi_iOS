import UIKit
import RxSwift
import RxCocoa

class ForgotPasswordController: UIViewController {

    // MARK: - view props
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    // MARK: - internal props
    weak var coordinator: MainCoordinator?
    let disposeBag = DisposeBag()
    var viewModel: ForgotPasswordViewModel!
    var spinnerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinnerView = UIView.init(frame: view.bounds)
        emailTextField.delegate = self
        
        viewModel = ForgotPasswordViewModel(userService: UserService())
        createViewModelBinding()
    }
}

// MARK: - Textfield delegate methods
extension ForgotPasswordController: UITextFieldDelegate {
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

//MARK: - view model bindings
extension ForgotPasswordController {
    private func createViewModelBinding() {
        // view prop bindings
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.emailViewModel.data)
            .disposed(by: disposeBag)
        
        forgotPasswordBtn.rx.tap.do(onNext: { [unowned self] in
            self.emailTextField.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            if self.viewModel.validateFields() {
                self.viewModel.forgotPassword()
            }
        }).disposed(by: disposeBag)
        
        // view modal bindings
        viewModel.emailViewModel.errorValue
            .asObservable()
            .bind(to: emailErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.success
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.removeSpinner(spinner: self.spinnerView)
                    // this is here soley for debugging purposes
                    self.presentMessage(title: "Success",
                                        message: "Check your email for instructions to reset your password")
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
                    self.forgotPasswordBtn.enabled()
                } else {
                    self.forgotPasswordBtn.disabled()
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

