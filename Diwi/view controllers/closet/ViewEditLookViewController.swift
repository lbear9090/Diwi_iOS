//
//  ViewEditLookController.swift
//  Diwi
//
//  Created by Dominique Miller on 4/13/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class ViewEditLookController: UIViewController {
    
    // MARK: - view props
    let navHeader           = NavHeader()
    let titleField          = MDCTextField()
    var titleController     = MDCTextInputControllerUnderline()
    let scrollView          = UIScrollView()
    var spinnerView         = UIView()
    let contentView         = UIView()
    let lookImage           = UIImageView()
    let lookItems           = HeaderSectionsForCollectionViews.closet(TextContent.Labels.lookItems).view()
    let whereIWoreIt        = HeaderSectionsForCollectionViews.events(TextContent.Labels.whereIWoreIt).view()
    let whenIWoreIt         = HeaderSectionsForCollectionViews.dates(TextContent.Labels.whenIworeIt).view()
    let whoIWoreItWith      = HeaderSectionsForCollectionViews.contacts(TextContent.Labels.whoIWoreItWith).view()
    let note                = UITextView()
    let dateLabel           = UILabel()
    let dateAdded           = UILabel()
    var saveButton          = AppButton()
    var cancelButton        = AppButton()
    
    // MARK: - internal props
    var viewModel: ViewEditLookViewModel!
    let disposeBag = DisposeBag()
    var goBack: (() -> Void)?
    var addClosetItems: ((_ items: [ModelDefault]) -> Void)?
    var addEvents: ((_ items: [ModelDefault]) -> Void)?
    var addDates: (() -> Void)?
    var addContacts: (() -> Void)?
    var goToSearch: (() -> Void)?
    var goToDetail: ((_ ofType: ModelType, _ id: Int) -> Void)?
    var scrollContainerBottomConstraint: NSLayoutConstraint?
    var closetCollectionView: UICollectionView!
    var closetCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    var eventCollectionView: UICollectionView!
    var eventCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    var datesCollectionView: UICollectionView!
    var datesCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    var contactsCollectionView: UICollectionView!
    var contactsCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    var coordinator: MainCoordinator?
    var viewMode: ViewingMode {
        return self.viewModel.getViewMode()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        lookImage.image = #imageLiteral(resourceName: "sample_image")
        
        navHeader.leftButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
//        setupBindings()
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(keyboardWillShow),
//                                               name:UIResponder.keyboardWillShowNotification, object: nil);
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(keyboardWillHide),
//                                               name:UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update collections when returning from outside flow
        guard let coord = coordinator else { return }
        
        if coord.selectedClothingItems.count > 0 {
           viewModel.updateClothingItems(with: coord.selectedClothingItems)
        }
        
        if coord.selectedEvents.count > 0 {
            viewModel.updateEvents(with: coord.selectedEvents)
        }
        
        if let newDate = coord.selectedDate {
            viewModel.updateDates(with: newDate)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let bottomConstraint = scrollContainerBottomConstraint,
            note.isFirstResponder else { return }
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       animations: { () -> Void in
                        bottomConstraint.constant = -200
                        self.view.layoutIfNeeded()
        }) { value in
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.adjustedContentInset.bottom)
                self.scrollView.setContentOffset(bottomOffset, animated: true)
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
         guard let bottomConstraint = scrollContainerBottomConstraint,
                   note.isFirstResponder else { return }
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       animations: { () -> Void in
                        bottomConstraint.constant = 0
                        self.view.layoutIfNeeded()
        })
    }
}

// MARK: - Setup bindings
extension ViewEditLookController: UITextFieldDelegate {
    private func setupBindings() {
        viewModel.dateAdded
            .drive(onNext: { [unowned self] dateString in
                self.dateAdded.text = dateString
            }).disposed(by: disposeBag)
        
        viewModel
            .title
            .skip(1)
            .asObservable()
            .map { $0 }
            .bind(to:self.titleField.rx.text)
            .disposed(by:self.disposeBag)
        
        viewModel.note
            .asObservable()
            .skip(1)
            .map { $0 }
            .bind(to:self.note.rx.text)
            .disposed(by:self.disposeBag)
        
        viewModel.mainImage
            .skip(1)
            .drive(onNext: { [unowned self] imageUrl in
                if !imageUrl.isEmpty {
                    self.lookImage.kf.setImage(with: URL(string: imageUrl), options: [])
                } else {
                    self.lookImage.backgroundColor = UIColor.Diwi.gray
                }
            }).disposed(by: disposeBag)
        
        viewModel.viewMode
            .drive(onNext: { [unowned self] mode in
                self.reloadCollectionViews()
        }).disposed(by: disposeBag)
        
        viewModel.errorMessage
            .skip(1)
            .drive(onNext: { [unowned self] message in
                self.presentError(message)
            }).disposed(by: disposeBag)
        
        viewModel.clothingItems
            .skip(1)
            .drive(onNext: { [unowned self] items in
                self.setClosetCollectionViewHeight()
                self.closetCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                self.closetCollectionView.layoutIfNeeded()
                self.closetCollectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.events
            .skip(1)
            .drive(onNext: { [unowned self] items in
                self.setEventCollectionViewHeight()
                self.eventCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                self.eventCollectionView.layoutIfNeeded()
                self.eventCollectionView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.datesWorn
            .skip(1)
            .drive(onNext: { [unowned self] items in
                self.setDateCollectionViewHeight()
                self.datesCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                self.datesCollectionView.layoutIfNeeded()
                self.datesCollectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.contacts
            .skip(1)
            .drive(onNext: { [unowned self] items in
                self.setContactCollectionViewHeight()
                self.contactsCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                self.contactsCollectionView.layoutIfNeeded()
                self.contactsCollectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: { [unowned self] value in
                if value {
                    self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
                } else {
                    self.removeSpinner(spinner: self.spinnerView)
                }
            }).disposed(by: disposeBag)
        
        viewModel.formValid
            .drive(onNext: { [unowned self] value in
                if value {
                    self.saveButton.enableButton()
                } else {
                    self.saveButton.disableButton()
                }
            }).disposed(by: disposeBag)
        
        viewModel.success
            .drive(onNext: { [unowned self] value in
                if value {
                    self.goBack?()
                }
            }).disposed(by: disposeBag)
        
        // MARK: - Button bindings
        lookItems.button.rx.tap.bind { [unowned self] in
            self.lookItems.button.buttonPressedAnimation {
                self.viewModel.updateViewingMode(to: .edit)
                let items = self.viewModel.getAllItemsFor(.ClothingItems)
                self.addClosetItems?(items)
            }
        }.disposed(by: disposeBag)
        
        whereIWoreIt.button.rx.tap.bind { [unowned self] in
            self.whereIWoreIt.button.buttonPressedAnimation {
                self.viewModel.updateViewingMode(to: .edit)
                let events = self.viewModel.getAllItemsFor(.Events)
                self.addEvents?(events)
            }
        }.disposed(by: disposeBag)
        
        whenIWoreIt.button.rx.tap.bind { [unowned self] in
            self.whenIWoreIt.button.buttonPressedAnimation {
                self.viewModel.updateViewingMode(to: .edit)
                self.addDates?()
            }
        }.disposed(by: disposeBag)
        
        whoIWoreItWith.button.rx.tap.bind { [unowned self] in
            self.whoIWoreItWith.button.buttonPressedAnimation {
                self.viewModel.updateViewingMode(to: .edit)
                self.addContacts?()
            }
        }.disposed(by: disposeBag)
        
        saveButton.rx.tap.bind { [unowned self] in
            self.saveButton.buttonPressedAnimation {
                self.viewModel.updateLook()
            }
        }.disposed(by: disposeBag)
        
        cancelButton.rx.tap.bind {
            self.cancelButton.buttonPressedAnimation {
                self.viewModel.resetView()
            }
        }.disposed(by: disposeBag)
        
        // MARK: - UITextView bindings
        note.rx.didBeginEditing.bind { [unowned self] in
            if self.note.textColor == UIColor.Diwi.fadedGray {
                self.viewModel.updateViewingMode(to: .edit)
                self.note.text = nil
                self.note.textColor = UIColor.black
            }
        }.disposed(by: disposeBag)
        
        note.rx.didEndEditing.bind { [unowned self] in
            if self.note.text.isEmpty {
                self.note.text = TextContent.Labels.addANote
                self.note.textColor = UIColor.lightGray
            }
        }.disposed(by: disposeBag)
        
        titleField.rx
            .controlEvent(.editingDidEnd)
            .bind { [unowned self] in
                self.viewModel.updateViewingMode(to: .edit)
                self.viewModel.validateForm()
        }.disposed(by: disposeBag)
        
        note.rx.text.orEmpty
          .bind(to: viewModel.note)
          .disposed(by: disposeBag)
        
        titleField.rx.text.orEmpty
            .bind(to: viewModel.title)
            .disposed(by: disposeBag)
        
    }
}

// MARK: - Setup View
extension ViewEditLookController {
    private func setupView() {
        setupSpinner()
        setupHeader()
        setupScrollView()
        setupContentView()
        setupLookImage()
        setupName()
        setupWhatIWoreView()
        setupClosetCollectionView()
        setupWhereIWentView()
        setupEventCollectionView()
        setupWhenIWentView()
        setupDatesCollectionView()
        setupwhoIWoreItWith()
        setupContactsCollectionView()
        setupNote()
        setupDate()
        setupSaveButton()
        setupCancelButton()
    }
    
    private func setupSpinner() {
        spinnerView = UIView.init(frame: view.bounds)
    }
    
    private func setupHeader() {
        navHeader.translatesAutoresizingMaskIntoConstraints = false
        navHeader.setup(backgroundColor: UIColor.Diwi.barney,
                        style: .normal,
                        navTitle: TextContent.Labels.myLook)
        
        navHeader.leftButtonAction = { [weak self] in
            self?.goBack?()
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
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.Diwi.yellow
        scrollView.keyboardDismissMode = .onDrag

        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollView.addGestureRecognizer(tap)

        view.addSubview(scrollView)

        scrollContainerBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navHeader.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollContainerBottomConstraint!
        ])
    }

    @objc func scrollViewTapped() {
        scrollView.endEditing(true)
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightConstraint.priority = UILayoutPriority(250) //very important
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            heightConstraint,
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.height)
        ])
    }
    
    private func setupLookImage() {
        lookImage.translatesAutoresizingMaskIntoConstraints = false
        lookImage.contentMode = .scaleAspectFill
        lookImage.clipsToBounds = true
        
        contentView.addSubview(lookImage)
        
        NSLayoutConstraint.activate([
            lookImage.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            lookImage.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            lookImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            lookImage.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    private func setupName() {
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.font? = UIFont.Diwi.textField
        titleField.tag = 0
        titleField.textColor = UIColor.Diwi.barney
        titleField.autocapitalizationType = .none
        titleField.autocorrectionType = .no
        titleField.delegate = self
        titleController = MDCTextInputControllerUnderline(textInput: titleField)
        titleController.textInputFont = UIFont.Diwi.textField
        titleField.placeholder = TextContent.Placeholders.lookTitle
        titleController.inlinePlaceholderColor = UIColor.Diwi.darkGray
        titleController.floatingPlaceholderActiveColor = UIColor.Diwi.darkGray
        titleController.activeColor = UIColor.Diwi.azure
        titleController.normalColor = UIColor.Diwi.azure
        
        contentView.addSubview(titleField)

        NSLayoutConstraint.activate([
            titleField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 30),
            titleField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30),
            titleField.topAnchor.constraint(equalTo: lookImage.bottomAnchor, constant: 35.5)
            ])
    }
    
    private func setupWhatIWoreView() {
        contentView.addSubview(lookItems)

        NSLayoutConstraint.activate([
           lookItems.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
           lookItems.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
           lookItems.topAnchor.constraint(equalTo: titleField.bottomAnchor),
           lookItems.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    private func setupClosetCollectionView() {
        closetCollectionView = CollectionsConfig.closet.collectionView()
        closetCollectionView.dataSource = self
        closetCollectionView.delegate = self
        
        contentView.addSubview(closetCollectionView!)

        closetCollectionViewHeight = closetCollectionView.heightAnchor.constraint(equalToConstant:0)
        NSLayoutConstraint.activate([
            closetCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            closetCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            closetCollectionView.topAnchor.constraint(equalTo: lookItems.bottomAnchor, constant: 10),
            closetCollectionViewHeight,
        ])

    }
    
    private func setupWhereIWentView() {
        contentView.addSubview(whereIWoreIt)

        NSLayoutConstraint.activate([
           whereIWoreIt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
           whereIWoreIt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
           whereIWoreIt.topAnchor.constraint(equalTo: closetCollectionView.bottomAnchor, constant: 20),
           whereIWoreIt.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    private func setupEventCollectionView() {
        eventCollectionView = CollectionsConfig.events.collectionView()
        eventCollectionView.delegate = self
        eventCollectionView.dataSource = self
        
        contentView.addSubview(eventCollectionView)

        eventCollectionViewHeight = eventCollectionView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            eventCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            eventCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            eventCollectionView.topAnchor.constraint(equalTo: whereIWoreIt.bottomAnchor, constant: 10),
            eventCollectionViewHeight,
        ])

    }
    
    private func setupWhenIWentView() {
        contentView.addSubview(whenIWoreIt)

        NSLayoutConstraint.activate([
           whenIWoreIt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
           whenIWoreIt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
           whenIWoreIt.topAnchor.constraint(equalTo: eventCollectionView.bottomAnchor, constant: 20),
           whenIWoreIt.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    private func setupDatesCollectionView() {
            datesCollectionView = CollectionsConfig.dates.collectionView()
            datesCollectionView.delegate = self
            datesCollectionView.dataSource = self
            
            contentView.addSubview(datesCollectionView)

            datesCollectionViewHeight = datesCollectionView.heightAnchor.constraint(equalToConstant: 0)

            NSLayoutConstraint.activate([
                datesCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
                datesCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
                datesCollectionView.topAnchor.constraint(equalTo: whenIWoreIt.bottomAnchor, constant: 10),
                datesCollectionViewHeight,
            ])

    }
    
    private func setupwhoIWoreItWith() {
        contentView.addSubview(whoIWoreItWith)

        NSLayoutConstraint.activate([
           whoIWoreItWith.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
           whoIWoreItWith.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
           whoIWoreItWith.topAnchor.constraint(equalTo: datesCollectionView.bottomAnchor, constant: 20),
           whoIWoreItWith.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    private func setupContactsCollectionView() {
        contactsCollectionView = CollectionsConfig.contacts.collectionView()
        contactsCollectionView.delegate = self
        contactsCollectionView.dataSource = self
        
        contentView.addSubview(contactsCollectionView)

        contactsCollectionViewHeight = contactsCollectionView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            contactsCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contactsCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contactsCollectionView.topAnchor.constraint(equalTo: whoIWoreItWith.bottomAnchor, constant: 10),
            contactsCollectionViewHeight,
        ])
    }
    
    private func setupNote() {
        note.translatesAutoresizingMaskIntoConstraints = false
        note.layer.cornerRadius = 5
        note.layer.borderColor = UIColor.Diwi.azure.cgColor
        note.layer.borderWidth = 1
        note.text = TextContent.Labels.addANote
        note.textColor = UIColor.Diwi.fadedGray
        note.font = UIFont.Diwi.textField
        note.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        
        contentView.addSubview(note)
        
        NSLayoutConstraint.activate([
            note.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 30),
            note.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30),
            note.heightAnchor.constraint(equalToConstant: 178),
            note.topAnchor.constraint(equalTo: contactsCollectionView.bottomAnchor, constant: 30)
        ])
        
    }
    
    private func setupDate() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.Diwi.textField
        dateLabel.textColor = UIColor.Diwi.azure
        dateLabel.text = TextContent.Labels.dateAdded
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: note.bottomAnchor, constant: 33),
            dateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 30)
            ])
        
        dateAdded.translatesAutoresizingMaskIntoConstraints = false
        dateAdded.font = UIFont.Diwi.textField
        dateAdded.textColor = UIColor.Diwi.darkGray
        contentView.addSubview(dateAdded)
        
        NSLayoutConstraint.activate([
            dateAdded.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            dateAdded.leftAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: 5)
            ])
    }
    
    private func setupSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.titleLabel?.font = UIFont.Diwi.button
        saveButton.setTitle(TextContent.Buttons.saveLook, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        
        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            saveButton.topAnchor.constraint(equalTo: dateAdded.bottomAnchor, constant: 26),
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.inverseColor()
        cancelButton.titleLabel?.font = UIFont.Diwi.button
        cancelButton.setTitle(TextContent.Buttons.cancel, for: .normal)
        cancelButton.setTitleColor(UIColor.Diwi.barney, for: .normal)
        
        contentView.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 26),
            cancelButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -25)
        ])
    }
}

// MARK: - Collection View delagate methods
extension ViewEditLookController: UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout {

    private func reloadCollectionViews() {
        closetCollectionView.reloadData()
        eventCollectionView.reloadData()
        datesCollectionView.reloadData()
        contactsCollectionView.reloadData()
    }
    
    func setClosetCollectionViewHeight() {
        closetCollectionViewHeight.constant = 125
    }

    func setEventCollectionViewHeight() {
        let newHeight = CollectionsConfig.events.viewHeightCalculator(numberOfItems: viewModel.eventsCount())
        eventCollectionViewHeight.constant = newHeight
    }

    func setDateCollectionViewHeight() {
        let newHeight = CollectionsConfig.dates.viewHeightCalculator(numberOfItems: viewModel.datesCount())
        datesCollectionViewHeight.constant = newHeight
    }
    
    func setContactCollectionViewHeight() {
        let newHeight = CollectionsConfig.contacts.viewHeightCalculator(numberOfItems: viewModel.contactsCount())
        contactsCollectionViewHeight.constant = newHeight
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //Still need this but it break if it's not commented out for now. 
        
//        switch collectionView {
//        case eventCollectionView:
//            return viewModel.eventsCount()
//        case datesCollectionView:
//            return viewModel.datesCount()
//        case closetCollectionView:
//            return viewModel.clothingItemsCount()
//        case contactsCollectionView:
//            return viewModel.contactsCount()
//        default:
//            return 0
//        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        switch collectionView {
        case datesCollectionView:
            return CollectionsConfig.dates.cgSizeForItem
        case eventCollectionView:
            return CollectionsConfig.events.cgSizeForItem
        case closetCollectionView:
            return CollectionsConfig.closet.cgSizeForItem
        case contactsCollectionView:
            return CollectionsConfig.contacts.cgSizeForItem
        default:
            return CGSize(width: 0 , height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case eventCollectionView:
            return CollectionsConfig.events.minimumLineSpacingForSectionAt
        case datesCollectionView:
            return CollectionsConfig.dates.minimumLineSpacingForSectionAt
        case closetCollectionView:
            return CollectionsConfig.closet.minimumLineSpacingForSectionAt
        case contactsCollectionView:
            return CollectionsConfig.contacts.minimumLineSpacingForSectionAt
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case eventCollectionView:
            return CollectionsConfig.events.minimumLineSpacingForSectionAt
        case datesCollectionView:
            return CollectionsConfig.dates.minimumLineSpacingForSectionAt
        case closetCollectionView:
            return CollectionsConfig.closet.minimumLineSpacingForSectionAt
        case contactsCollectionView:
            return CollectionsConfig.contacts.minimumLineSpacingForSectionAt
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case eventCollectionView:
            return CollectionsConfig.events.insetForSectionAt
        case datesCollectionView:
            return CollectionsConfig.dates.insetForSectionAt
        case closetCollectionView:
            return CollectionsConfig.closet.insetForSectionAt
        case contactsCollectionView:
            return CollectionsConfig.contacts.insetForSectionAt
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        switch collectionView {
        case contactsCollectionView:
            let contact = viewModel.getContact(at: indexPath.row)
            if let id = contact.id {
                self.goToDetail?(.Contacts, id)
            }
        case closetCollectionView:
            let item = viewModel.getClothingItem(at: indexPath.row)
            if let id = item.id {
                self.goToDetail?(.ClothingItems, id)
            }
        case eventCollectionView:
            let event = viewModel.getEvent(at: indexPath.row)
            if let id = event.id {
                self.goToDetail?(.Events, id)
            }
        default:
            print("Do nothing")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case eventCollectionView:
            let cell = setupEventCell(for: indexPath)
            return cell
        case datesCollectionView:
            let cell = setupDateCell(for: indexPath)
            return cell
        case closetCollectionView:
            let cell = setupClosetCell(for: indexPath)
            return cell
        case contactsCollectionView:
            let cell = setupContactCell(for: indexPath)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    private func setupEventCell(for indexPath: IndexPath) -> OblongCollectionViewCell {
        let cell: OblongCollectionViewCell = eventCollectionView.dequeueReusableCell(for: indexPath)
        let event = viewModel.getEvent(at: indexPath.row)
        
        // If event has no title provide default Text
        if let name = event.name, !name.isEmpty {
            cell.configure(with: name, id: event.id, mode: viewMode)
        } else {
            cell.configure(with: TextContent.Labels.event, id: event.id, mode: viewMode)
        }
        
        cell.remove = { [weak self] (name, id) in
            self?.viewModel.removeEvent(item: event)
        }
        
        return cell
    }
    
    private func setupDateCell(for indexPath: IndexPath) -> OblongCollectionViewCell {
        let cell: OblongCollectionViewCell = datesCollectionView.dequeueReusableCell(for: indexPath)
        let date = viewModel.getDate(at: indexPath.row)
        
        cell.configure(with: date, id: nil, mode: viewMode)
        cell.remove = { [weak self] (name, id) in
            self?.viewModel.removeFromDates(date: date)
        }
        
        return cell
    }
    
    private func setupClosetCell(for indexPath: IndexPath) -> ClosetCell {
        let cell: ClosetCell = closetCollectionView.dequeueReusableCell(for: indexPath)
        let item = viewModel.getClothingItem(at: indexPath.row)
        
        cell.indexItem = item
        cell.removeClosetItem = { [weak self] _ in
            self?.viewModel.removeClothingItem(item: item)
        }
        cell.setup(mode: .items)
        cell.showDeleteButton = viewMode == .edit ? true : false
        
        return cell
    }
    
    private func setupContactCell(for indexPath: IndexPath) -> OblongCollectionViewCell {
        let cell: OblongCollectionViewCell = eventCollectionView.dequeueReusableCell(for: indexPath)
        let contact = viewModel.getContact(at: indexPath.row)
        if let name = contact.title {
            cell.configure(with: name, id: contact.id, mode: viewMode)
        }
        cell.remove = { [weak self] (name, id) in
            self?.viewModel.removeContact(contact: contact)
        }
        
        return cell
    }
}
