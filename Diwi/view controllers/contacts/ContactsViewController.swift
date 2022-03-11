//
//  ContactsViewController.swift
//  Diwi
//
//  Created by Dominique Miller on 3/23/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContactsViewController: UIViewController {
    
    // MARK: - view props
    let navHeader         = NavHeader()
    let emptyMessage      = AppButton()
    let contactsTable     = UITableView()
    let sideBar           = UIView()
    let alphabetStackView = UIStackView()
    let addButton         = UIButton()
    var spinnerView       = UIView()
    
    // MARK: - internal props
    let disposeBag = DisposeBag()
    var goToHomePage: (() -> Void)?
    var goToContact: ((_ id: Int) -> Void)?
    var goToRemoveContacts: (() -> Void)?
    var goToNewContact: (() -> Void)?
    var goToSearch: (() -> Void)?
    var viewModel: ContactsViewModel!
    let screenWidth = UIScreen.main.bounds.width
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.resetTags()
    }
}

// MARK: - Setup bindings
extension ContactsViewController {
    private func setupBindings() {
        addButton.rx.tap.bind { [unowned self] in
            self.goToNewContact?()
        }.disposed(by: disposeBag)

        emptyMessage.rx.tap.bind {
            self.goToNewContact?()
        }.disposed(by: disposeBag)
        
        viewModel
            .contacts
            .skip(1)
            .drive(onNext: { [unowned self] value in
                if value.count > 0 {
                    self.removeEmptyState()
                    self.contactsTable.isHidden = false
                    self.sideBar.isHidden = false
                    self.contactsTable.reloadData()
                } else if value.count == 0 {
                    self.contactsTable.isHidden = true
                    self.sideBar.isHidden = true
                    self.setupEmptyState()
                }
                
            }).disposed(by: disposeBag)
        
        viewModel.errorMessage.drive(onNext: {[unowned self] value in
            if !value.isEmpty {
               self.presentError(value)
            }
        }).disposed(by: disposeBag)
        
        // always skip the initial value
        viewModel.indexPathToScrollTo
            .skip(1)
            .drive(onNext: {[unowned self] value in
            self.contactsTable.scrollToRow(at: value, at: .top, animated: true)
        }).disposed(by: disposeBag)
        
        // MARK: - Table view bindings
        contactsTable.rx
            .modelSelected(Tag.self)
            .subscribe(onNext: { [unowned self] value in
                guard let id = value.id else { return }
                self.goToContact?(id)
        }).disposed(by: disposeBag)
        
        contactsTable.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.contacts.asObservable()
            .bind(to: contactsTable.rx.items(cellIdentifier: ContactCell.identifier,
                                             cellType: ContactCell.self)) {  row, element, cell in
                                                cell.contact = self.viewModel.getContact(with: row)
                                                cell.setup()
        }.disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
                } else {
                    self.removeSpinner(spinner: self.spinnerView)
                }
        }).disposed(by: disposeBag)
    }
}

// MARK: - Setup View
extension ContactsViewController {
    private func setupView() {
        spinnerView = UIView.init(frame: view.bounds)
        
        setupHeader()
        setupContactsTable()
        setupFooter()
        setupSideBar()
        setupAddButton()
        setupAlphabetStackView()
        setupAlphabetButtons()
    }
    
    private func setupHeader() {
        navHeader.translatesAutoresizingMaskIntoConstraints = false
        navHeader.setup(backgroundColor: UIColor.Diwi.contactGray,
                        style: .tabBar,
                        navTitle: TextContent.Labels.contacts)
        
        navHeader.leftButtonAction = { [weak self] in
            self?.goToHomePage?()
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
    
    private func setupContactsTable() {
        contactsTable.translatesAutoresizingMaskIntoConstraints = false
        contactsTable.register(ContactCell.self, forCellReuseIdentifier: ContactCell.identifier)
        contactsTable.separatorStyle = .none
        
        view.addSubview(contactsTable)
        
        NSLayoutConstraint.activate([
            contactsTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            contactsTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            contactsTable.topAnchor.constraint(equalTo: navHeader.bottomAnchor, constant: 23),
            contactsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSideBar() {
        sideBar.translatesAutoresizingMaskIntoConstraints = false
        sideBar.backgroundColor = .white
        
        view.addSubview(sideBar)
        
        NSLayoutConstraint.activate([
            sideBar.widthAnchor.constraint(equalToConstant: 69),
            sideBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            sideBar.topAnchor.constraint(equalTo: navHeader.bottomAnchor),
            sideBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        ])
    }
    
    private func setupAddButton() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage.Diwi.addIconWhite, for: .normal)
        
        sideBar.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 59),
            addButton.widthAnchor.constraint(equalToConstant: 59),
            addButton.bottomAnchor.constraint(equalTo: sideBar.bottomAnchor, constant: -45),
            addButton.centerXAnchor.constraint(equalTo: sideBar.centerXAnchor),
        ])
    }
    
    private func setupAlphabetStackView() {
        alphabetStackView.translatesAutoresizingMaskIntoConstraints = false
        alphabetStackView.alignment = .center
        alphabetStackView.distribution = .equalSpacing
        alphabetStackView.axis = .vertical
        
        sideBar.addSubview(alphabetStackView)
        
        NSLayoutConstraint.activate([
            alphabetStackView.topAnchor.constraint(equalTo: sideBar.topAnchor, constant: 24),
            alphabetStackView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -18),
            alphabetStackView.centerXAnchor.constraint(equalTo: sideBar.centerXAnchor)
        ])
    }
    
    private func setupAlphabetButtons() {
        let chars = viewModel.alphabetArray
        
        for (index, char) in chars.enumerated() {
            let button = UIButton()
            button.setTitle(char, for: .normal)
            button.setTitleColor(UIColor.Diwi.azure, for: .normal)
            button.titleLabel?.font = UIFont.Diwi.smallText
            button.tag = index
            
            alphabetStackView.addArrangedSubview(button)
            
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 14)
            ])
            
            button.rx.tap.bind { [unowned self] in
                self.viewModel.scrollToIndexValue(for: button.tag)
            }.disposed(by: disposeBag)
        }
    }
    
    private func setupEmptyState() {
        emptyMessage.translatesAutoresizingMaskIntoConstraints = false
        emptyMessage.inverseColor()
        emptyMessage.setTitle(TextContent.Buttons.addFriends, for: .normal)
        emptyMessage.setTitleColor(UIColor.Diwi.barney, for: .normal)
        emptyMessage.titleLabel?.font = UIFont.Diwi.button
        
        view.addSubview(emptyMessage)
        
        NSLayoutConstraint.activate([
            emptyMessage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            emptyMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyMessage.heightAnchor.constraint(equalToConstant: 50),
            emptyMessage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            emptyMessage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30)
        ])
    }
    
    private func removeEmptyState() {
        emptyMessage.removeFromSuperview()
    }
    
    private func setupFooter() {
        // MARK: - Set tableview footer
        let footerView = TableViewFooter(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 150))
        
        footerView.setup(text: TextContent.Labels.removeFriends, style: .normal)
        
        footerView.buttonPressed = { [weak self] in
            self?.goToRemoveContacts?()
        }
        
        contactsTable.tableFooterView = footerView
    }
}

// MARK: - Table View Delegate methods
extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfContacts()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let contact = viewModel.getContact(with: indexPath.row)
        if contact.hasImages() {
            return 160
        } else {
            return 40
        }
    }
}
