//
//  RemoveContactsViewController.swift
//  Diwi
//
//  Created by Dominique Miller on 3/30/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa

class RemoveContactsViewController: UIViewController {
    
    // MARK: - view props
    let navHeader         = NavHeader()
    let emptyMessage      = AppButton()
    let contactsTable     = UITableView()
    let sideBar           = UIView()
    let alphabetStackView = UIStackView()
    let removeContacts     = AppButton()
    
    // MARK: - internal props
    let disposeBag = DisposeBag()
    var goBack: (() -> Void)?
    var goToGlobalSearch: (() -> Void)?
    var goToRemoveContacts: (([Int]) -> Void)?
    var viewModel: ContactsViewModel!
    let screenWidth = UIScreen.main.bounds.width
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
}

// MARK: - Setup bindings
extension RemoveContactsViewController {
    private func setupBindings() {
        removeContacts.rx.tap.bind {
            let ids = self.viewModel.getItemsToBeDeleted()
            if ids.count > 0 {
              self.goToRemoveContacts?(ids)
            }
        }.disposed(by: disposeBag)
        
        emptyMessage.rx.tap.bind {
            self.presentError("Sorry I'm under construction!")
        }.disposed(by: disposeBag)
        
        viewModel
            .contacts
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
        
        // MARK: - Table view bindings
        contactsTable.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.contacts.asObservable()
            .bind(to: contactsTable.rx.items(cellIdentifier: ContactCell.identifier,
                                             cellType: ContactCell.self)) {  row, element, cell in
                                                cell.contact = self.viewModel.getContact(with: row)
                                                cell.setup()
                                                cell.showDeleteButton = true
        }.disposed(by: disposeBag)
        
    }
}

// MARK: - Setup View
extension RemoveContactsViewController {
    private func setupView() {
        setupHeader()
        setupRemoveFriends()
        setupContactsTable()
        setupSideBar()
        setupAlphabetStackView()
        setupAlphabetButtons()
    }
    
    private func setupHeader() {
        navHeader.translatesAutoresizingMaskIntoConstraints = false
        navHeader.setup(backgroundColor: UIColor.Diwi.contactGray,
                        style: .backButtonOnly,
                        navTitle: TextContent.Labels.removeFriends)
        
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
    
    private func setupRemoveFriends() {
        removeContacts.translatesAutoresizingMaskIntoConstraints = false
        removeContacts.setTitle(TextContent.Labels.removeFriends, for: .normal)
        removeContacts.titleLabel?.font = UIFont.Diwi.button
        
        view.addSubview(removeContacts)
        
        NSLayoutConstraint.activate([
            removeContacts.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            removeContacts.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            removeContacts.heightAnchor.constraint(equalToConstant: 50),
            removeContacts.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
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
            contactsTable.bottomAnchor.constraint(equalTo: removeContacts.topAnchor, constant: -15)
        ])
    }
    
    private func setupSideBar() {
        sideBar.translatesAutoresizingMaskIntoConstraints = false
        sideBar.backgroundColor = .white
        
        view.addSubview(sideBar)
        
        NSLayoutConstraint.activate([
            sideBar.widthAnchor.constraint(equalToConstant: 60),
            sideBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            sideBar.topAnchor.constraint(equalTo: navHeader.bottomAnchor),
            sideBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
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
            alphabetStackView.bottomAnchor.constraint(equalTo: sideBar.bottomAnchor, constant: 18),
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
}

// MARK: - Table View Delegate methods
extension RemoveContactsViewController: UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ContactCell,
            let id = cell.contact?.id else { return }
        
        if cell.selectedForDeletion {
            viewModel.removeItemToBeDeleted(id: id)
            cell.selectedForDeletion = false
        } else {
            viewModel.addItemToBeDeleted(id: id)
            cell.selectedForDeletion = true
        }
    }
}

