//
//  ChooseWhoViewController.swift
//  Diwi
//
//  Created by Jae Lee on 11/7/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class ChooseWhoViewController: UIViewController, UITextFieldDelegate {
    let navHeader           = NavHeader()
    let name                = MDCTextField()
    var nameController      = MDCTextInputControllerUnderline()
    let tableView           = UITableView()
    let addPeopleButton     = AppButton()
    let plusButton          = UIButton()
    let plusButtonContainer = UIView()
    
    var viewModel: ChooseWhoViewModel!
    
    let disposeBag = DisposeBag()
    
    var finished: (() -> Void)?
    var goToSearch: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupView()
        setupBindings()
    }
    
    private func addNewPersonToTags() {
        let text = self.name.text ?? ""
        self.viewModel.updateTagsArray(newName: text)
        self.name.text = ""
        self.name.resignFirstResponder()
    }
}


extension ChooseWhoViewController {
    private func setupBindings() {
        viewModel.tags
            .subscribe(onNext: { [unowned self] value in
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        addPeopleButton.rx.tap.bind {
            let text = self.name.text ?? ""
            self.viewModel.updateTagsArray(newName: text)
            self.finished?()
        }.disposed(by: disposeBag)
        
        plusButton.rx.tap.bind {
            self.plusButton.buttonPressedAnimation {
                self.addNewPersonToTags()
            }
        }.disposed(by: disposeBag)
        
        name.rx.controlEvent(.editingDidEndOnExit).bind {
            self.addNewPersonToTags()
        }.disposed(by: disposeBag)
    }
}


extension ChooseWhoViewController {
    private func setupView() {
        setupHeader()
        setupName()
        setupPlusButton()
        setupTableView()
        setupAddPeopleButton()
    }
    
    private func setupHeader() {
        navHeader.translatesAutoresizingMaskIntoConstraints = false
        navHeader.setup(backgroundColor: UIColor.Diwi.contactGray,
                        style: .normal,
                        navTitle: TextContent.Labels.whoDidIWearItWith)
        
        navHeader.leftButtonAction = { [weak self] in
            self?.finished?()
        }
        
        navHeader.rightButtonAction = { [weak self] in
            self?.goToSearch?()
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
    
    private func setupName() {
        name.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(name)
        name.font? = UIFont.Diwi.textField
        name.tag = 0
        name.textColor = UIColor.Diwi.darkGray
        name.autocapitalizationType = .none
        name.autocorrectionType = .no
        name.delegate = self
        nameController = MDCTextInputControllerUnderline(textInput: name)
        name.placeholder = TextContent.Placeholders.nameOfEvent
        name.placeholder = "Who was at the event?"
        nameController.inlinePlaceholderColor = UIColor.Diwi.darkGray
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
        tableView.delegate = self
        tableView.dataSource = self
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
    
    private func setupAddPeopleButton() {
        addPeopleButton.translatesAutoresizingMaskIntoConstraints = false
        addPeopleButton.enableButton()
        addPeopleButton.setTitle(TextContent.Buttons.saveFriends, for: .normal)
        
        view.addSubview(addPeopleButton)
        
        NSLayoutConstraint.activate([
            addPeopleButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            addPeopleButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            addPeopleButton.heightAnchor.constraint(equalToConstant: 50),
            addPeopleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
    }
}


extension ChooseWhoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tags.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.identifier, for: indexPath) as! AutocompleteCell
        cell.tagData = viewModel.tags.value[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AutocompleteCell
        cell.toggle()
    }
    
}
