//
//  AddEventViewController.swift
//  Diwi
//
//  Created by Jae Lee on 10/24/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons
//
//class AddEventViewController: UIViewController, UITextFieldDelegate {
//
//    // view props
//    let scrollView          = UIScrollView()
//    let contentView         = UIView()
//    let header              = UIView()
//    let subHeader           = UIView()
//    let navTitle            = UILabel()
//    let backIcon            = UIButton()
//    let dateCircleContainer = UIView()
//    let cheersIcon          = UIImageView(image: UIImage.Diwi.cheersIcon)
//    let name                = MDCTextField()
//    var nameController      = MDCTextInputControllerUnderline()
//    let whatDidIWearView    = HeaderSectionsForCollectionViews.closet(TextContent.Labels.whatDidIWear).view()
//    let whoWasThereView     = HeaderSectionsForCollectionViews.contacts(TextContent.Labels.whoWasThere).view()
//    let whenWasTheEvent     = HeaderSectionsForCollectionViews.dates(TextContent.Labels.whenWasTheEvent).view()
//    var timeView            = AppTextFieldView()
//    var locationView        = AppTextFieldView()
//    let dateLabel           = UILabel()
//    let dateAdded           = UILabel()
//    let note                = UITextView()
//    var saveButton          = UIButton()
//    var spinnerView         = UIView()
//
//    // internal props
//    var pickDate: (() -> Void)?
//    var pickWhoWasAtEvent: (() -> Void)?
//    var addLocation: (() -> Void)?
//    var addClosetItems: ((_ items: [ClothingItem], _ looks: [Look]) -> Void)?
//    var addContacts: (() -> Void)?
//    var addDate: (() -> Void)?
//    var finished: (() -> Void)?
//    var eventCreated: (() -> Void)?
//    var coordinator: MainCoordinator?
//    var scrollContainerBottomConstraint: NSLayoutConstraint?
//    var closetCollectionView: UICollectionView!
//    var closetCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
//    var contactsCollectionView: UICollectionView!
//    var contactsCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
//
//    let disposeBag = DisposeBag()
//    var viewModel: AddEventViewModel!
//    //var imagePicker: ImagePickerService!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupView()
//        setupBindings()
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(keyboardWillShow),
//                                               name:UIResponder.keyboardWillShowNotification, object: nil);
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(keyboardWillHide),
//                                               name:UIResponder.keyboardWillHideNotification, object: nil);
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        viewModel.vaidateForm()
//
//        // update collections when returning from outside flow
//        guard let coord = coordinator else { return }
//
//        if coord.selectedClothingItems.count > 0 {
//           viewModel.updateClothingItems(with: coord.selectedClothingItems)
//        }
//
//        if coord.selectedLooks.count > 0 {
//            viewModel.updateLooks(with: coord.selectedLooks)
//        }
//
//        if let newDate = coord.selectedDate {
//            viewModel.updateDateWith(with: newDate)
//        }
//
//    }
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//
//    @objc func keyboardWillShow(notification: NSNotification) {
//         guard let bottomConstraint = scrollContainerBottomConstraint,
//                   note.isFirstResponder else { return }
//
//        UIView.animate(withDuration: 0.2,
//                       delay: 0.0,
//                       animations: { () -> Void in
//                        bottomConstraint.constant = -200
//                        self.view.layoutIfNeeded()
//        }) { value in
//            UIView.animate(withDuration: 0.2, animations: { () -> Void in
//                let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.adjustedContentInset.bottom)
//                self.scrollView.setContentOffset(bottomOffset, animated: true)
//                self.view.layoutIfNeeded()
//            })
//        }
//
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//         guard let bottomConstraint = scrollContainerBottomConstraint,
//                   note.isFirstResponder else { return }
//
//        UIView.animate(withDuration: 0.2,
//                       delay: 0.0,
//                       animations: { () -> Void in
//                        bottomConstraint.constant = 0
//                        self.view.layoutIfNeeded()
//        })
//    }
//}
//
//// MARK: - Setup bindings
//extension AddEventViewController {
//    private func setupBindings() {
//        viewModel.dateAdded
//            .asObservable()
//            .skip(1)
//            .map { $0 }
//            .bind(to:self.dateAdded.rx.text)
//            .disposed(by:self.disposeBag)
//
//        viewModel.time
//            .asObservable()
//            .bind(to: timeView.textField.rx.text)
//            .disposed(by: disposeBag)
//
//        viewModel.closetItems
//            .subscribe(onNext: { [unowned self] items in
//                if items.count > 0 {
//                    self.setClosetCollectionViewHeight()
//                    self.closetCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
//                    self.closetCollectionView.layoutIfNeeded()
//                    self.closetCollectionView.reloadData()
//                }
//            }).disposed(by: disposeBag)
//
//        viewModel.contacts
//            .skip(1)
//            .subscribe(onNext: { [unowned self] items in
//                self.setContactCollectionViewHeight()
//                self.contactsCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
//                self.contactsCollectionView.layoutIfNeeded()
//                self.contactsCollectionView.reloadData()
//            }).disposed(by: disposeBag)
//
//        viewModel.dateAdded
//            .subscribe(onNext: { [unowned self] value in
//            self.dateAdded.text = value
//        }).disposed(by: disposeBag)
//
//        viewModel.eventDate
//            .subscribe(onNext: { [unowned self] dateString in
//                self.whenWasTheEvent.textField.text = dateString
//        }).disposed(by: disposeBag)
//
//        viewModel.formIsValid
//            .subscribe(onNext: { [unowned self] value in
//                if value {
//                    self.saveButton.enabled()
//                }
//        }).disposed(by: disposeBag)
//
//        viewModel.location
//            .subscribe(onNext: { [unowned self] (value) in
//                if !value.isEmpty {
//                   self.locationView.textField.text = value
//                }
//        }).disposed(by: disposeBag)
//
//        viewModel.isLoading
//        .subscribe(onNext: { [unowned self] (value: Bool) in
//            if value {
//                self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
//            } else {
//                self.removeSpinner(spinner: self.spinnerView)
//            }
//        }).disposed(by: disposeBag)
//
//        viewModel.success
//            .subscribe(onNext: { [unowned self] (value) in
//                if value {
//                    self.eventCreated?()
//                }
//        }).disposed(by: disposeBag)
//        // MARK: - UIButton bindings
//        backIcon.rx.tap.bind {
//            self.finished?()
//        }.disposed(by: disposeBag)
//
//        saveButton.rx.tap.bind {
//            self.saveButton.buttonPressedAnimation {
//                self.viewModel.createEvent()
//            }
//        }.disposed(by: disposeBag)
//
//        timeView.button.rx.tap.bind {
//            self.pickDate?()
//        }.disposed(by: disposeBag)
//
//        locationView.button.rx.tap.bind {
//            self.addLocation?()
//        }.disposed(by: disposeBag)
//
//        whatDidIWearView.button.rx
//            .tap.bind { [unowned self] in
//            self.whatDidIWearView.button.buttonPressedAnimation {
//                if let items = self.viewModel.getAllItemsFor(.ClothingItems) as? [ClothingItem],
//                    let looks = self.viewModel.getAllItemsFor(.Looks) as? [Look] {
//                    self.addClosetItems?(items, looks)
//                }
//            }
//        }.disposed(by: disposeBag)
//
//        whenWasTheEvent.button.rx
//            .tap.bind { [unowned self] in
//            self.whenWasTheEvent.button.buttonPressedAnimation {
//                self.addDate?()
//            }
//        }.disposed(by: disposeBag)
//
//        whoWasThereView.button.rx
//            .tap.bind { [unowned self] in
//                self.whoWasThereView.button.buttonPressedAnimation {
//                    self.addContacts?()
//                }
//        }.disposed(by: disposeBag)
//
//        // MARK: - UITextView bindings
//        note.rx.didBeginEditing.bind { [unowned self] in
//            if self.note.textColor == UIColor.Diwi.fadedGray {
//                self.note.text = nil
//                self.note.textColor = UIColor.black
//            }
//        }.disposed(by: disposeBag)
//
//        note.rx.didEndEditing.bind { [unowned self] in
//            if self.note.text.isEmpty {
//                self.note.text = TextContent.Labels.addANote
//                self.note.textColor = UIColor.lightGray
//            }
//        }.disposed(by: disposeBag)
//
//        note.rx.text.orEmpty
//          .bind(to: viewModel.note)
//          .disposed(by: disposeBag)
//
//        name.rx.text
//            .orEmpty
//            .bind(to: viewModel.name)
//            .disposed(by: disposeBag)
//    }
//
//}
//
//// MARK: - Setup view
//extension AddEventViewController {
//    private func setupView() {
//        view.backgroundColor = UIColor.white
//        setupSpinner()
//        setupHeader()
//        setupNav()
//        setupScrollView()
//        setupContentView()
//        setupSubHeader()
//        setupCheersIcon()
//        setupEventName()
//        setupWhatDidIWearView()
//        setupClosetCollectionView()
//        setupWhoWasThere()
//        setupContactsCollectionView()
//        setupWhenWasTheEventView()
//        setupTimeView()
//        setuplocationView()
//        setupNote()
//        setupDate()
//        setupSaveEventButton()
//        setupImagePicker()
//    }
//
//    private func setupSpinner() {
//        spinnerView = UIView.init(frame: view.bounds)
//    }
//
//    private func setupHeader() {
//        header.translatesAutoresizingMaskIntoConstraints = false
//        header.backgroundColor = UIColor.Diwi.azure
//        view.addSubview(header)
//
//        var height: NSLayoutConstraint
//        if hasNotch() {
//            height = header.heightAnchor.constraint(equalToConstant: 90)
//        }
//        else {
//            height = header.heightAnchor.constraint(equalToConstant: 60)
//        }
//
//        NSLayoutConstraint.activate([
//            header.leftAnchor.constraint(equalTo: view.leftAnchor),
//            header.rightAnchor.constraint(equalTo: view.rightAnchor),
//            header.topAnchor.constraint(equalTo: view.topAnchor),
//            height
//            ])
//    }
//
//    private func setupNav() {
//        backIcon.translatesAutoresizingMaskIntoConstraints = false
//        backIcon.setImage(UIImage.Diwi.backIconWhite, for: .normal)
//        header.addSubview(backIcon)
//
//        var paddingTop = CGFloat(25)
//        if hasNotch() {
//            paddingTop += 30
//        }
//
//        NSLayoutConstraint.activate([
//            backIcon.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
//            backIcon.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10),
//            backIcon.widthAnchor.constraint(equalToConstant: 25),
//            backIcon.heightAnchor.constraint(equalToConstant: 25)
//        ])
//
//        navTitle.translatesAutoresizingMaskIntoConstraints = false
//        navTitle.textColor = UIColor.white
//        navTitle.text = TextContent.Labels.addEvent
//        navTitle.font = UIFont.Diwi.titleBold
//        header.addSubview(navTitle)
//
//        NSLayoutConstraint.activate([
//            navTitle.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
//            navTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor),
//        ])
//    }
//    private func setupScrollView() {
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.backgroundColor = UIColor.Diwi.azure
//        scrollView.keyboardDismissMode = .onDrag
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
//        scrollView.addGestureRecognizer(tap)
//
//        view.addSubview(scrollView)
//
//        scrollContainerBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
//            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
//            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
//            scrollContainerBottomConstraint!
//        ])
//    }
//
//    @objc func scrollViewTapped() {
//        scrollView.endEditing(true)
//    }
//
//    private func setupContentView() {
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.backgroundColor = .white
//        let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
//        heightConstraint.priority = UILayoutPriority(250) //very important
//        scrollView.addSubview(contentView)
//        NSLayoutConstraint.activate([
//            heightConstraint,
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.height)
//        ])
//
//    }
//
//    private func setupSubHeader() {
//        subHeader.translatesAutoresizingMaskIntoConstraints = false
//        subHeader.backgroundColor = UIColor.Diwi.azure
//        contentView.addSubview(subHeader)
//
//        NSLayoutConstraint.activate([
//            subHeader.leftAnchor.constraint(equalTo: view.leftAnchor),
//            subHeader.rightAnchor.constraint(equalTo: view.rightAnchor),
//            subHeader.topAnchor.constraint(equalTo: contentView.topAnchor),
//            subHeader.heightAnchor.constraint(equalToConstant: 121)
//        ])
//    }
//
//
//    private func setupCheersIcon() {
//        cheersIcon.translatesAutoresizingMaskIntoConstraints = false
//
//        contentView.addSubview(cheersIcon)
//
//        NSLayoutConstraint.activate([
//            cheersIcon.centerYAnchor.constraint(equalTo: subHeader.bottomAnchor),
//            cheersIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            cheersIcon.widthAnchor.constraint(equalToConstant: 82),
//            cheersIcon.heightAnchor.constraint(equalToConstant: 82),
//        ])
//    }
//
//    private func setupEventName() {
//        name.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(name)
//        name.font? = UIFont.Diwi.textField
//        name.tag = 0
//        name.textColor = UIColor.Diwi.darkGray
//        name.autocapitalizationType = .none
//        name.autocorrectionType = .no
//        name.delegate = self
//        nameController = MDCTextInputControllerUnderline(textInput: name)
//        name.placeholder = TextContent.Placeholders.nameOfEvent
//        nameController.inlinePlaceholderColor = UIColor.Diwi.darkGray
//        nameController.floatingPlaceholderNormalColor = UIColor.Diwi.darkGray
//        nameController.floatingPlaceholderActiveColor = UIColor.Diwi.darkGray
//        nameController.activeColor = UIColor.Diwi.azure
//        nameController.normalColor = UIColor.Diwi.azure
//
//        NSLayoutConstraint.activate([
//            name.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
//            name.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
//            name.topAnchor.constraint(equalTo: cheersIcon.bottomAnchor, constant: 31.5)
//            ])
//    }
//
//    private func setupWhatDidIWearView() {
//        contentView.addSubview(whatDidIWearView)
//
//        NSLayoutConstraint.activate([
//           whatDidIWearView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
//           whatDidIWearView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
//           whatDidIWearView.topAnchor.constraint(equalTo: name.bottomAnchor),
//           whatDidIWearView.heightAnchor.constraint(equalToConstant: 24),
//        ])
//    }
//
//    private func setupClosetCollectionView() {
//        closetCollectionView = CollectionsConfig.closet.collectionView()
//        closetCollectionView.dataSource = self
//        closetCollectionView.delegate = self
//
//        contentView.addSubview(closetCollectionView!)
//
//        closetCollectionViewHeight = closetCollectionView.heightAnchor.constraint(equalToConstant:0)
//        NSLayoutConstraint.activate([
//            closetCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
//            closetCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
//            closetCollectionView.topAnchor.constraint(equalTo: whatDidIWearView.bottomAnchor, constant: 20),
//            closetCollectionViewHeight,
//        ])
//
//    }
//
//    private func setupWhoWasThere() {
//        scrollView.addSubview(whoWasThereView)
//
//        NSLayoutConstraint.activate([
//           whoWasThereView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
//           whoWasThereView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
//           whoWasThereView.topAnchor.constraint(equalTo: closetCollectionView.bottomAnchor, constant: 20),
//           whoWasThereView.heightAnchor.constraint(equalToConstant: 28),
//        ])
//    }
//
//    private func setupContactsCollectionView() {
//        contactsCollectionView = CollectionsConfig.contacts.collectionView()
//        contactsCollectionView.delegate = self
//        contactsCollectionView.dataSource = self
//
//        scrollView.addSubview(contactsCollectionView)
//
//        contactsCollectionViewHeight = contactsCollectionView.heightAnchor.constraint(equalToConstant: 0)
//
//        NSLayoutConstraint.activate([
//            contactsCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
//            contactsCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
//            contactsCollectionView.topAnchor.constraint(equalTo: whoWasThereView.bottomAnchor, constant: 10),
//            contactsCollectionViewHeight,
//        ])
//    }
//
//    private func setupWhenWasTheEventView() {
//        scrollView.addSubview(whenWasTheEvent)
//
//        NSLayoutConstraint.activate([
//            whenWasTheEvent.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
//            whenWasTheEvent.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
//            whenWasTheEvent.topAnchor.constraint(equalTo: contactsCollectionView.bottomAnchor, constant: 20),
//            whenWasTheEvent.heightAnchor.constraint(equalToConstant: 28),
//        ])
//    }
//
//    private func setupTimeView() {
//        timeView.translatesAutoresizingMaskIntoConstraints = false
//        timeView.setImage(UIImage.Diwi.clockIcon, height: 20, width: 20)
//        viewModel.time.accept(TextContent.Labels.time)
//        timeView.textField.isEnabled = false
//        contentView.addSubview(timeView)
//
//        NSLayoutConstraint.activate([
//            timeView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
//            timeView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
//            timeView.topAnchor.constraint(equalTo: whenWasTheEvent.bottomAnchor, constant: 20),
//            timeView.heightAnchor.constraint(equalToConstant: 28)
//        ])
//    }
//
//    private func setuplocationView() {
//        locationView.translatesAutoresizingMaskIntoConstraints = false
//        locationView.setImage(UIImage.Diwi.locationIcon)
//        locationView.setTitle(TextContent.Labels.location)
//        locationView.textField.isEnabled = false
//
//        contentView.addSubview(locationView)
//
//        NSLayoutConstraint.activate([
//            locationView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
//            locationView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
//            locationView.topAnchor.constraint(equalTo: timeView.bottomAnchor, constant: 20),
//            locationView.heightAnchor.constraint(equalToConstant: 28)
//        ])
//    }
//
//    private func setupNote() {
//        note.translatesAutoresizingMaskIntoConstraints = false
//        note.layer.cornerRadius = 5
//        note.layer.borderColor = UIColor.Diwi.azure.cgColor
//        note.layer.borderWidth = 1
//        note.text = TextContent.Labels.addANote
//        note.textColor = UIColor.Diwi.fadedGray
//        note.font = UIFont.Diwi.textField
//        note.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
//
//        contentView.addSubview(note)
//
//        NSLayoutConstraint.activate([
//            note.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 30),
//            note.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30),
//            note.heightAnchor.constraint(equalToConstant: 178),
//            note.topAnchor.constraint(equalTo: locationView.bottomAnchor, constant: 30)
//        ])
//
//    }
//
//    private func setupDate() {
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateLabel.font = UIFont.Diwi.textField
//        dateLabel.textColor = UIColor.Diwi.azure
//        dateLabel.text = TextContent.Labels.dateAdded
//        contentView.addSubview(dateLabel)
//
//        NSLayoutConstraint.activate([
//            dateLabel.topAnchor.constraint(equalTo: note.bottomAnchor, constant: 33),
//            dateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 30)
//            ])
//
//        dateAdded.translatesAutoresizingMaskIntoConstraints = false
//        dateAdded.font = UIFont.Diwi.textField
//        dateAdded.textColor = UIColor.Diwi.darkGray
//        contentView.addSubview(dateAdded)
//
//        NSLayoutConstraint.activate([
//            dateAdded.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
//            dateAdded.leftAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: 5)
//            ])
//    }
//
//    private func setupSaveEventButton() {
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
//        saveButton.titleLabel?.font = UIFont.Diwi.floatingButton
//        saveButton.setTitle(TextContent.Buttons.saveEvent, for: .normal)
//        saveButton.setTitleColor(.white, for: .normal)
//        saveButton.backgroundColor = UIColor.Diwi.barney
//        saveButton.roundAllCorners(radius: 25)
//        saveButton.disabled()
//        contentView.addSubview(saveButton)
//
//        let bottomConstraint = saveButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -75)
//        bottomConstraint.priority = UILayoutPriority(500)
//
//        NSLayoutConstraint.activate([
//            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            saveButton.heightAnchor.constraint(equalToConstant: 50),
//            saveButton.widthAnchor.constraint(equalToConstant: 315),
//            saveButton.topAnchor.constraint(equalTo: dateAdded.bottomAnchor, constant: 36),
//            bottomConstraint
//        ])
//    }
//
//    private func setupImagePicker() {
//        self.imagePicker = ImagePickerService(presentationController: self, delegate: self)
//    }
//}
//
//// MARK: - Collection view data source delegate methods
//extension AddEventViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func setClosetCollectionViewHeight() {
//        closetCollectionViewHeight.constant = 125
//    }
//
//    func setContactCollectionViewHeight() {
//        let newHeight = CollectionsConfig.contacts.viewHeightCalculator(numberOfItems: viewModel.contactsCount())
//        contactsCollectionViewHeight.constant = newHeight
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch collectionView {
//        case closetCollectionView:
//            return viewModel.closetItemsCount()
//        case contactsCollectionView:
//            return viewModel.contactsCount()
//        default:
//            return 0
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        switch collectionView {
//        case closetCollectionView:
//            return CollectionsConfig.closet.cgSizeForItem
//        case contactsCollectionView:
//            return CollectionsConfig.contacts.cgSizeForItem
//        default:
//            return CGSize(width: 0 , height: 0)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        switch collectionView {
//        case closetCollectionView:
//            return CollectionsConfig.closet.minimumLineSpacingForSectionAt
//        case contactsCollectionView:
//            return CollectionsConfig.contacts.minimumLineSpacingForSectionAt
//        default:
//            return 0
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        switch collectionView {
//        case closetCollectionView:
//            return CollectionsConfig.closet.minimumLineSpacingForSectionAt
//        case contactsCollectionView:
//            return CollectionsConfig.contacts.minimumLineSpacingForSectionAt
//        default:
//            return 0
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        switch collectionView {
//        case closetCollectionView:
//            return CollectionsConfig.closet.insetForSectionAt
//        case contactsCollectionView:
//            return CollectionsConfig.contacts.insetForSectionAt
//        default:
//            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch collectionView {
//        case closetCollectionView:
//            let cell = setupClosetCell(for: indexPath)
//            return cell
//        case contactsCollectionView:
//            let cell = setupContactCell(for: indexPath)
//            return cell
//        default:
//            return UICollectionViewCell()
//        }
//    }
//
//    private func setupClosetCell(for indexPath: IndexPath) -> ClosetCell {
//        let cell: ClosetCell = closetCollectionView.dequeueReusableCell(for: indexPath)
//        let item = viewModel.getClosetItem(at: indexPath.row)
//
//        cell.indexItem = item
//        cell.removeClosetItem = { [weak self] _ in
//            self?.viewModel.removeClosetItem(item: item)
//        }
//        cell.setup(mode: .items)
//        cell.showDeleteButton = true
//
//        return cell
//    }
//
//    private func setupContactCell(for indexPath: IndexPath) -> OblongCollectionViewCell {
//        let cell: OblongCollectionViewCell = contactsCollectionView.dequeueReusableCell(for: indexPath)
//        let contact = viewModel.getContact(at: indexPath.row)
//        if let name = contact.title {
//            cell.configure(with: name, id: contact.id, mode: .edit)
//        }
//        cell.remove = { [weak self] (name, id) in
//            self?.viewModel.removeContact(contact: contact)
//        }
//
//        return cell
//    }
//}
//
//extension AddEventViewController {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.viewModel.vaidateForm()
//        textField.resignFirstResponder()
//        return true
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.viewModel.vaidateForm()
//    }
//}
//
//extension AddEventViewController: ImagePickerDelegate {
//    func didSelect(image: UIImage?) {
//        guard image != nil else {return}
//        imagePicker.vc.dismiss(animated: true)
//    }
//}
