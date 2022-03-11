//
//  AddContactViewController.swift
//  Diwi
//
//  Created by Dominique Miller on 3/31/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class AddContactViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - view props
    let navHeader           = NavHeader()
    let saveFriends         = AppButton()
    let name                = MDCTextField()
    var nameController      = MDCTextInputControllerUnderline()
    let tableView           = UITableView()
    let plusButton          = UIButton()
    let plusButtonContainer = UIView()
    
    // MARK: - internal props
    var viewModel: AddContactsViewModel!
    let disposeBag = DisposeBag()
    var goBack: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func addNewNameToTags() {
        let text = self.name.text ?? ""
        self.viewModel.updateTagsArray(newName: text)
        self.name.text = ""
        self.name.resignFirstResponder()
    }
}

// MARK: - Setup bindings
extension AddContactViewController {
    private func setupBindings() {
       plusButton.rx.tap.bind {
            self.plusButton.buttonPressedAnimation {
                self.addNewNameToTags()
            }
        }.disposed(by: disposeBag)
        
        saveFriends.rx.tap.bind { [unowned self] in
            self.viewModel.createTags() { [weak self] in
                self?.goBack?()
            }
        }.disposed(by: disposeBag)
        
        name.rx.controlEvent(.editingDidEndOnExit).bind {
            self.addNewNameToTags()
        }.disposed(by: disposeBag)
        
        viewModel.tags
            .subscribe(onNext: { [unowned self] (value: [Tag]) in
                self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.tags.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: AutocompleteCell.identifier,
                                             cellType: AutocompleteCell.self)) {  row, element, cell in
                                                cell.tagData = self.viewModel.tags.value[row]
        }.disposed(by: disposeBag)
        
        viewModel.duplicateTag
            .subscribe(onNext: { [unowned self] value in
                if value {
                    self.presentMessage(title: TextContent.Alert.duplicateName,
                                        message: TextContent.Alert.duplicateNameMessage)
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Setup view
extension AddContactViewController {
    private func setupView() {
        setupHeader()
        setupNameField()
        setupPlusButton()
        setupTableView()
        setupSaveFriends()
    }
    
    private func setupHeader() {
        navHeader.translatesAutoresizingMaskIntoConstraints = false
        navHeader.setup(backgroundColor: UIColor.Diwi.contactGray,
                        style: .backButtonOnly,
                        navTitle: TextContent.Labels.addFriends)
        
        navHeader.leftButtonAction = { [weak self] in
            self?.goBack?()
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
    
    private func setupNameField() {
        name.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(name)
        name.font? = UIFont.Diwi.textField
        name.tag = 0
        name.textColor = UIColor.Diwi.darkGray
        name.autocapitalizationType = .none
        name.autocorrectionType = .no
        name.delegate = self
        nameController = MDCTextInputControllerUnderline(textInput: name)
        nameController.textInputFont = UIFont.Diwi.textField
        nameController.inlinePlaceholderFont = UIFont.Diwi.textField
        name.placeholder = TextContent.Placeholders.addNewFriend
        nameController.inlinePlaceholderColor = UIColor.Diwi.azure
        nameController.floatingPlaceholderNormalColor = UIColor.Diwi.darkGray
        nameController.floatingPlaceholderActiveColor = UIColor.Diwi.darkGray
        nameController.activeColor = UIColor.Diwi.azure
        nameController.normalColor = UIColor.Diwi.azure
        nameController.trailingUnderlineLabelTextColor = .clear

        NSLayoutConstraint.activate([
            name.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            name.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            name.topAnchor.constraint(equalTo: navHeader.bottomAnchor, constant: 31.5)
        ])
    }
    
    private func setupPlusButton() {
        plusButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        plusButtonContainer.backgroundColor = .white
        
        view.addSubview(plusButtonContainer)
        
        NSLayoutConstraint.activate([
            plusButtonContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            plusButtonContainer.centerYAnchor.constraint(equalTo: name.centerYAnchor, constant: -1),
            plusButtonContainer.widthAnchor.constraint(equalToConstant: 34),
            plusButtonContainer.heightAnchor.constraint(equalToConstant: 29)
        ])
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setImage(UIImage.Diwi.addIcon_noBackground, for: .normal)
        
        plusButtonContainer.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.centerXAnchor.constraint(equalTo: plusButtonContainer.centerXAnchor, constant: 4),
            plusButton.centerYAnchor.constraint(equalTo: plusButtonContainer.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 28),
            plusButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(AutocompleteCell.self, forCellReuseIdentifier: AutocompleteCell.identifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 15),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 47),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -47),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -85)
        ])
    }
    
    private func setupSaveFriends() {
        saveFriends.translatesAutoresizingMaskIntoConstraints = false
        saveFriends.enableButton()
        saveFriends.setTitle(TextContent.Buttons.saveFriends, for: .normal)
        
        view.addSubview(saveFriends)
        
        NSLayoutConstraint.activate([
            saveFriends.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            saveFriends.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            saveFriends.heightAnchor.constraint(equalToConstant: 50),
            saveFriends.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
    }
}

// MARK: - Table View delegate methods
extension AddContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfTags()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AutocompleteCell
        cell.toggle()
    }
}
