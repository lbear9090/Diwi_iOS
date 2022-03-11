//
//  LocationForm.swift
//  Diwi
//
//  Created by Dominique Miller on 11/19/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class LocationFormViewController: UIViewController {
    
    // MARK: - view props
    let navHeader           = NavHeader()
    let formContainer       = UIStackView()
    let address             = MDCTextField()
    var addressController   = MDCTextInputControllerUnderline()
    let city                = MDCTextField()
    var cityController      = MDCTextInputControllerUnderline()
    let state               = MDCTextField()
    var stateController     = MDCTextInputControllerUnderline()
    let zipCode             = MDCTextField()
    var zipCodeController   = MDCTextInputControllerUnderline()
    let saveLocation        = AppButton()
    let arrowIcon           = UIImageView()
    
    // MARK: - interanl props
    let disposeBag = DisposeBag()
    var statePicker = UIPickerView()
    var pickerToolbar = UIToolbar()
    var numericKeyboardToolbar = UIToolbar()
    var states = States()
    var formContainerYCenterConstraint: NSLayoutConstraint?
    var viewModel: EditEventOrAddEventViewModel!
    var finished: (() -> Void)?
    
    // MARK: - lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name:UIResponder.keyboardWillHideNotification, object: nil);
        
        setupView()
        setupBindings()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let centerConstraint = formContainerYCenterConstraint else { return }
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       animations: { () -> Void in
                        centerConstraint.constant = -100
                        self.view.layoutIfNeeded()
        })
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let centerConstraint = formContainerYCenterConstraint else { return }
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       animations: { () -> Void in
                        centerConstraint.constant = 0
                        self.view.layoutIfNeeded()
        })
    }
    
}

// MARK: - SetupView
extension LocationFormViewController: UITextFieldDelegate {
    private func setupView() {
        view.backgroundColor = UIColor.white
        setupHeader()
        setupFormContainer()
        setupAddress()
        setupCity()
        setupStatePicker()
        setupPickerToolbar()
        setupState()
        setupNumericKeyboardToolbar()
        setupZipCode()
        setupSaveLocation()
    }
    
    private func setupHeader() {
        navHeader.translatesAutoresizingMaskIntoConstraints = false
        navHeader.setup(backgroundColor: UIColor.Diwi.azure,
                        style: .backButtonOnly,
                        navTitle: TextContent.Labels.addLocation)
        
        navHeader.leftButtonAction = { [weak self] in
            self?.finished?()
        }
        
        view.backgroundColor = UIColor.white
        view.addSubview(navHeader)
        
        var headerHeight: CGFloat = 60
        
        if hasNotch() {
            headerHeight += 30
        }
        
        NSLayoutConstraint.activate([
            navHeader.leftAnchor.constraint(equalTo: view.leftAnchor),
            navHeader.rightAnchor.constraint(equalTo: view.rightAnchor),
            navHeader.topAnchor.constraint(equalTo: view.topAnchor),
            navHeader.heightAnchor.constraint(equalToConstant: headerHeight)
        ])
    }
    
    private func setupFormContainer() {
        formContainer.translatesAutoresizingMaskIntoConstraints = false
        formContainer.distribution = .equalSpacing
        formContainer.alignment = .center
        formContainer.axis = .vertical
        formContainer.spacing = 16
        
        formContainerYCenterConstraint = formContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        
        view.addSubview(formContainer)
        
        NSLayoutConstraint.activate([
            formContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            formContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            formContainerYCenterConstraint!
            ])
    }
    
    private func setupAddress() {
        address.translatesAutoresizingMaskIntoConstraints = false
        address.font? = UIFont.Diwi.textField
        address.textColor = UIColor.Diwi.darkGray
        address.autocapitalizationType = .none
        address.autocorrectionType = .no
        address.delegate = self
        addressController = MDCTextInputControllerUnderline(textInput: address)
        address.placeholder = TextContent.Placeholders.address
        addressController.inlinePlaceholderColor = UIColor.Diwi.darkGray
        addressController.floatingPlaceholderNormalColor = UIColor.Diwi.darkGray
        addressController.floatingPlaceholderActiveColor = UIColor.Diwi.darkGray
        addressController.activeColor = UIColor.Diwi.azure
        addressController.normalColor = UIColor.Diwi.azure
        
        formContainer.addArrangedSubview(address)

        NSLayoutConstraint.activate([
            address.heightAnchor.constraint(equalToConstant: 48),
            address.widthAnchor.constraint(equalTo: formContainer.widthAnchor)
            ])
    }
    
    private func setupStatePicker() {
        statePicker.layer.backgroundColor = UIColor.white.cgColor
        statePicker.delegate = self
        statePicker.dataSource = self
    }
    
    private func setupPickerToolbar() {
        pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(sender:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        pickerToolbar.setItems([flexibleSpace,flexibleSpace, doneButton], animated: true)
    }
    
    @objc func doneButtonPressed(sender: UIBarButtonItem) {
       state.resignFirstResponder()
       formValidationCheck()
    }
    
    private func setupCity() {
        city.translatesAutoresizingMaskIntoConstraints = false
        city.font? = UIFont.Diwi.textField
        city.textColor = UIColor.Diwi.darkGray
        city.autocapitalizationType = .none
        city.autocorrectionType = .no
        city.delegate = self
        cityController = MDCTextInputControllerUnderline(textInput: city)
        city.placeholder = TextContent.Placeholders.city
        cityController.inlinePlaceholderColor = UIColor.Diwi.darkGray
        cityController.floatingPlaceholderNormalColor = UIColor.Diwi.darkGray
        cityController.floatingPlaceholderActiveColor = UIColor.Diwi.darkGray
        cityController.activeColor = UIColor.Diwi.azure
        cityController.normalColor = UIColor.Diwi.azure
        
        formContainer.addArrangedSubview(city)

        NSLayoutConstraint.activate([
            city.heightAnchor.constraint(equalToConstant: 48),
            city.widthAnchor.constraint(equalTo: formContainer.widthAnchor)
            ])
    }
    
    private func setupState() {
        state.translatesAutoresizingMaskIntoConstraints = false
        state.font? = UIFont.Diwi.textField
        state.textColor = UIColor.Diwi.darkGray
        state.autocapitalizationType = .none
        state.autocorrectionType = .no
        state.delegate = self
        state.inputAccessoryView = pickerToolbar
        state.inputView = statePicker
        stateController = MDCTextInputControllerUnderline(textInput: state)
        state.placeholder = TextContent.Placeholders.state
        stateController.inlinePlaceholderColor = UIColor.Diwi.darkGray
        stateController.floatingPlaceholderNormalColor = UIColor.Diwi.darkGray
        stateController.floatingPlaceholderActiveColor = UIColor.Diwi.darkGray
        stateController.activeColor = UIColor.Diwi.azure
        stateController.normalColor = UIColor.Diwi.azure
        
        arrowIcon.translatesAutoresizingMaskIntoConstraints = false
        arrowIcon.image = UIImage.Diwi.pinkDownArrow
        state.rightView = arrowIcon
        state.rightViewMode = .always
        
        formContainer.addArrangedSubview(state)

        NSLayoutConstraint.activate([
            state.heightAnchor.constraint(equalToConstant: 48),
            state.widthAnchor.constraint(equalTo: formContainer.widthAnchor)
            ])
    }
    
    private func setupNumericKeyboardToolbar() {
        numericKeyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(numericKeyboardDoneButtonPressed(sender:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        numericKeyboardToolbar.setItems([flexibleSpace,flexibleSpace, doneButton], animated: true)
    }
    
    @objc func numericKeyboardDoneButtonPressed(sender: UIBarButtonItem) {
       zipCode.resignFirstResponder()
       formValidationCheck()
    }
    
    
    private func setupZipCode() {
        zipCode.translatesAutoresizingMaskIntoConstraints = false
        zipCode.font? = UIFont.Diwi.textField
        zipCode.textColor = UIColor.Diwi.darkGray
        zipCode.autocapitalizationType = .none
        zipCode.autocorrectionType = .no
        zipCode.keyboardType = .numberPad
        zipCode.inputAccessoryView = numericKeyboardToolbar
        zipCode.delegate = self
        zipCodeController = MDCTextInputControllerUnderline(textInput: zipCode)
        zipCode.placeholder = TextContent.Placeholders.zipCode
        zipCodeController.inlinePlaceholderColor = UIColor.Diwi.darkGray
        zipCodeController.floatingPlaceholderNormalColor = UIColor.Diwi.darkGray
        zipCodeController.floatingPlaceholderActiveColor = UIColor.Diwi.darkGray
        zipCodeController.activeColor = UIColor.Diwi.azure
        zipCodeController.normalColor = UIColor.Diwi.azure
        
        formContainer.addArrangedSubview(zipCode)

        NSLayoutConstraint.activate([
            zipCode.heightAnchor.constraint(equalToConstant: 48),
            zipCode.widthAnchor.constraint(equalTo: formContainer.widthAnchor)
            ])
    }
    
    private func setupSaveLocation() {
        saveLocation.translatesAutoresizingMaskIntoConstraints = false
        saveLocation.titleLabel?.font = UIFont.Diwi.floatingButton
        saveLocation.setTitle(TextContent.Labels.saveLocationToEvent, for: .normal)
        saveLocation.setTitleColor(.white, for: .normal)
        saveLocation.backgroundColor = UIColor.Diwi.barney
        saveLocation.roundAllCorners(radius: 25)
        saveLocation.disableButton()
        
        view.addSubview(saveLocation)
        
        NSLayoutConstraint.activate([
            saveLocation.heightAnchor.constraint(equalToConstant: 50),
            saveLocation.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            saveLocation.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            saveLocation.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        formValidationCheck()
        return true
    }
    
    private func formValidationCheck() {
        if viewModel.validateAddressFields() {
            saveLocation.enableButton()
        } else {
            saveLocation.disableButton()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        formValidationCheck()
    }
}

// MARK: - UIPicker Delegate methods
extension LocationFormViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.stateCount()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states.arr()[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        state.text = states.arr()[row].abbreviation
    }
}

// MARK: - Setup bindings
extension LocationFormViewController {
    private func setupBindings() {
        saveLocation.rx.tap.bind {
            self.saveLocation.buttonPressedAnimation {
                self.viewModel.setAddress()
                self.finished?()
            }
        }.disposed(by: disposeBag)
        
        viewModel.address.subscribe(onNext: { [unowned self] (value) in
            if !value.isEmpty {
                self.address.text = value
            }
        }).disposed(by: disposeBag)
        
        viewModel.city.subscribe(onNext: { [unowned self] (value) in
            if !value.isEmpty {
                self.city.text = value
            }
        }).disposed(by: disposeBag)
        
        viewModel.state.subscribe(onNext: { [unowned self] (value) in
            if !value.isEmpty {
                self.state.text = value
            }
        }).disposed(by: disposeBag)
        
        viewModel.zip.subscribe(onNext: { [unowned self] (value) in
            if !value.isEmpty {
                self.zipCode.text = value
            }
        }).disposed(by: disposeBag)
        
        address.rx.text.orEmpty
            .bind(to: viewModel.address)
            .disposed(by: disposeBag)
        
        city.rx.text.orEmpty
            .bind(to: viewModel.city)
            .disposed(by: disposeBag)
        
        state.rx.text.orEmpty
            .bind(to: viewModel.state)
            .disposed(by: disposeBag)
        
        zipCode.rx.text.orEmpty
            .bind(to: viewModel.zip)
            .disposed(by: disposeBag)
    }
}
