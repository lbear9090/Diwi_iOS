//
//  ViewUpdateContactViewController.swift
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

class ViewUpdateContactViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - view props
    let navHeader           = NavHeader()
    let name                = MDCTextField()
    var nameController      = MDCTextInputControllerUnderline()
    let scrollView          = UIScrollView()
    var spinnerView         = UIView()
    let contentView         = UIView()
    let whatIWoreView       = HeaderSectionsForCollectionViews.closet(TextContent.Labels.whatIWore).view()
    let whereIWentView      = HeaderSectionsForCollectionViews.events(TextContent.Labels.whereIWent).view()
    let whenIWentView       = HeaderSectionsForCollectionViews.dates(TextContent.Labels.whenIWentOut).view()
    let note                = UITextView()
    let dateLabel           = UILabel()
    let dateAdded           = UILabel()
    var saveButton          = AppButton()
    var cancelButton        = AppButton()
    
    // MARK: - internal props
    var viewModel: ViewEditContactViewModel!
    let disposeBag = DisposeBag()
    var goBack: (() -> Void)?
    var addClosetItems: ((_ items: [ClothingItem], _ looks: [Look]) -> Void)?
    var addEvents: ((_ items: [ModelDefault]) -> Void)?
    var addDates: (() -> Void)?
    var goToSearch: (() -> Void)?
    var goToDetail: ((_ ofType: ModelType, _ id: Int) -> Void)?
    var scrollContainerBottomConstraint: NSLayoutConstraint?
    var closetCollectionView: UICollectionView!
    var closetCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    var eventCollectionView: UICollectionView!
    var eventCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    var datesCollectionView: UICollectionView!
    var datesCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name:UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update collections when returning from outside flow
        guard let coord = coordinator else { return }
        
        if coord.selectedClothingItems.count > 0 {
           viewModel.updateClothingItems(with: coord.selectedClothingItems)
        }
        
        if coord.selectedLooks.count > 0 {
            viewModel.updateLooks(with: coord.selectedLooks)
        }
        
        if coord.selectedEvents.count > 0 {
            viewModel.updateEvents(with: coord.selectedEvents)
        }
        
        if let newDate = coord.selectedDate {
            viewModel.updateDatesWith(with: newDate)
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
extension ViewUpdateContactViewController {
    private func setupBindings() {
        // MARK: - View model bindings
        viewModel.dateAdded
          .asObservable()
          .skip(1)
          .map { $0 }
          .bind(to:self.dateAdded.rx.text)
          .disposed(by:self.disposeBag)
        
        viewModel.name
         .asObservable()
         .skip(1)
         .map { $0 }
         .bind(to:self.name.rx.text)
         .disposed(by:self.disposeBag)
        
        viewModel.note
            .asObservable()
            .skip(1)
            .map { $0 }
            .bind(to:self.note.rx.text)
            .disposed(by:self.disposeBag)
        
        viewModel.closetItems
            .subscribe(onNext: { [unowned self] items in
                if items.count > 0 {
                    self.setClosetCollectionViewHeight()
                    self.closetCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                    self.closetCollectionView.layoutIfNeeded()
                    self.closetCollectionView.reloadData()
                }
            }).disposed(by: disposeBag)
        
        viewModel.events
            .subscribe(onNext: { [unowned self] items in
                if items.count > 0 {
                    self.setEventCollectionViewHeight()
                    self.eventCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                    self.eventCollectionView.layoutIfNeeded()
                    self.eventCollectionView.reloadData()
                }
        }).disposed(by: disposeBag)
        
        viewModel.datesWith
            .subscribe(onNext: { [unowned self] items in
                if items.count > 0 {
                    self.setDateCollectionViewHeight()
                    self.datesCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                    self.datesCollectionView.layoutIfNeeded()
                    self.datesCollectionView.reloadData()
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
                } else {
                    self.removeSpinner(spinner: self.spinnerView)
                }
            }).disposed(by: disposeBag)
        
        viewModel.success
            .subscribe(onNext: { [unowned self] (value) in
                if value {
                    self.goBack?()
                }
            }).disposed(by: disposeBag)
        
        viewModel.viewMode
            .subscribe(onNext: { [unowned self] mode in
                self.reloadCollectionViews()
            }).disposed(by: disposeBag)
        
        // MARK: - Button bindings
        whatIWoreView.button.rx.tap.bind { [unowned self] in
            self.whatIWoreView.button.buttonPressedAnimation {
                self.viewModel.updateViewingMode(to: .edit)
                if let items = self.viewModel.getAllItemsFor(.ClothingItems) as? [ClothingItem],
                    let looks = self.viewModel.getAllItemsFor(.Looks) as? [Look] {
                    self.addClosetItems?(items, looks)
                }
            }
        }.disposed(by: disposeBag)
        
        whereIWentView.button.rx.tap.bind { [unowned self] in
            self.whereIWentView.button.buttonPressedAnimation {
                self.viewModel.updateViewingMode(to: .edit)
                let events = self.viewModel.getAllItemsFor(.Events)
                self.addEvents?(events)
            }
        }.disposed(by: disposeBag)
        
        whenIWentView.button.rx.tap.bind { [unowned self] in
            self.whenIWentView.button.buttonPressedAnimation {
                self.viewModel.updateViewingMode(to: .edit)
                self.addDates?()
            }
        }.disposed(by: disposeBag)
        
        saveButton.rx.tap.bind {
            self.saveButton.buttonPressedAnimation {
                self.viewModel.updateTag()
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
        
        note.rx.text.orEmpty
          .bind(to: viewModel.note)
          .disposed(by: disposeBag)
        
        name.rx
            .controlEvent(.editingDidBegin)
            .bind { [unowned self] in
            self.viewModel.updateViewingMode(to: .edit)
        }.disposed(by: disposeBag)
    }
}

// MARK: - Setup View
extension ViewUpdateContactViewController {
    private func setupView() {
        setupSpinner()
        setupHeader()
        setupScrollView()
        setupContentView()
        setupName()
        setupWhatIWoreView()
        setupClosetCollectionView()
        setupWhereIWentView()
        setupEventCollectionView()
        setupWhenIWentView()
        setupDatesCollectionView()
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
        navHeader.setup(backgroundColor: UIColor.Diwi.contactGray,
                        style: .backButtonOnly,
                        navTitle: TextContent.Labels.myFriend)
        
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
    
    private func setupName() {
        name.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(name)
        name.font? = UIFont.Diwi.textField
        name.tag = 0
        name.textColor = UIColor.Diwi.barney
        name.autocapitalizationType = .none
        name.autocorrectionType = .no
        name.delegate = self
        nameController = MDCTextInputControllerUnderline(textInput: name)
        nameController.inlinePlaceholderFont = UIFont.Diwi.textField
        nameController.textInputFont = UIFont.Diwi.textField
        name.placeholder = TextContent.Placeholders.friendName
        nameController.inlinePlaceholderColor = UIColor.Diwi.barney
        nameController.floatingPlaceholderNormalColor = .clear
        nameController.floatingPlaceholderActiveColor = UIColor.Diwi.darkGray
        nameController.underlineViewMode = .whileEditing
        nameController.activeColor = UIColor.Diwi.azure
        nameController.normalColor = .clear

        NSLayoutConstraint.activate([
            name.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 30),
            name.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30),
            name.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 35.5)
            ])
    }
    
    private func setupWhatIWoreView() {
        contentView.addSubview(whatIWoreView)

        NSLayoutConstraint.activate([
           whatIWoreView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
           whatIWoreView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
           whatIWoreView.topAnchor.constraint(equalTo: name.bottomAnchor),
           whatIWoreView.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    private func setupClosetCollectionView() {
        closetCollectionView = CollectionsConfig.closet.collectionView()
        closetCollectionView.dataSource = self
        closetCollectionView.delegate = self
        
        contentView.addSubview(closetCollectionView!)

        closetCollectionViewHeight = closetCollectionView.heightAnchor.constraint(equalToConstant:0)
        NSLayoutConstraint.activate([
            closetCollectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            closetCollectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            closetCollectionView.topAnchor.constraint(equalTo: whatIWoreView.bottomAnchor, constant: 20),
            closetCollectionViewHeight,
        ])

    }
    
    private func setupWhereIWentView() {
        contentView.addSubview(whereIWentView )

        NSLayoutConstraint.activate([
           whereIWentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
           whereIWentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
           whereIWentView.topAnchor.constraint(equalTo: closetCollectionView.bottomAnchor, constant: 20),
           whereIWentView.heightAnchor.constraint(equalToConstant: 28),
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
            eventCollectionView.topAnchor.constraint(equalTo: whereIWentView.bottomAnchor, constant: 0),
            eventCollectionViewHeight,
        ])

    }
    
    private func setupWhenIWentView() {
        contentView.addSubview(whenIWentView)

        NSLayoutConstraint.activate([
           whenIWentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
           whenIWentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
           whenIWentView.topAnchor.constraint(equalTo: eventCollectionView.bottomAnchor, constant: 20),
           whenIWentView.heightAnchor.constraint(equalToConstant: 28),
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
                datesCollectionView.topAnchor.constraint(equalTo: whenIWentView.bottomAnchor, constant: 0),
                datesCollectionViewHeight,
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
            note.topAnchor.constraint(equalTo: datesCollectionView.bottomAnchor, constant: 30)
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
        saveButton.setTitle(TextContent.Buttons.saveFriend, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        
        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            saveButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 25)
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.inverseColor()
        cancelButton.setTitle(TextContent.Labels.cancel, for: .normal)
        cancelButton.titleLabel?.font = UIFont.Diwi.button
        cancelButton.setTitleColor(UIColor.Diwi.barney, for: .normal)
        
        contentView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -25)
        ])
    }
}

// MARK: - Collection View delagate methods
extension ViewUpdateContactViewController: UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout {

    private func reloadCollectionViews() {
        closetCollectionView.reloadData()
        eventCollectionView.reloadData()
        datesCollectionView.reloadData()
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case eventCollectionView:
            return viewModel.eventsCount()
        case datesCollectionView:
            return viewModel.datesCount()
        case closetCollectionView:
            return viewModel.closetItemsCount()
        default:
            return 0
        }
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
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        switch collectionView {
        case eventCollectionView:
            let event = viewModel.getEvent(at: indexPath.row)
            if let id = event.id {
                self.goToDetail?(.Events, id)
            }
        case closetCollectionView:
            let item = viewModel.getClosetItem(at: indexPath.row)
            if let id = item.id, item as? ClothingItem != nil {
                self.goToDetail?(.ClothingItems, id)
            }
            
            if let id = item.id, item as? Look != nil {
                self.goToDetail?(.Looks, id)
            }
        default:
            print("Do nothing")
        }
    }
    
    private func setupEventCell(for indexPath: IndexPath) -> OblongCollectionViewCell {
        let cell: OblongCollectionViewCell = eventCollectionView.dequeueReusableCell(for: indexPath)
        let event = viewModel.getEvent(at: indexPath.row)
        
        // If event has no title provide default Text
        if let name = event.name, !name.isEmpty {
            cell.configure(with: name, id: event.id, mode: .edit)
        } else {
            cell.configure(with: "Event", id: event.id, mode: .edit)
        }
        
        cell.remove = { [weak self] (name, id) in
            self?.viewModel.removeEvent(item: event)
        }
        
        return cell
    }
    
    private func setupDateCell(for indexPath: IndexPath) -> OblongCollectionViewCell {
        let cell: OblongCollectionViewCell = datesCollectionView.dequeueReusableCell(for: indexPath)
        let date = viewModel.getDate(at: indexPath.row)
        
        cell.configure(with: date, id: nil, mode: viewModel.viewMode.value)
        cell.remove = { [weak self] (name, id) in
            self?.viewModel.removeFromDateWith(date: date)
        }
        
        return cell
    }
    
    private func setupClosetCell(for indexPath: IndexPath) -> ClosetCell {
        let cell: ClosetCell = closetCollectionView.dequeueReusableCell(for: indexPath)
        let item = viewModel.getClosetItem(at: indexPath.row)
        
        cell.indexItem = item
        cell.removeClosetItem = { [weak self] _ in
            self?.viewModel.removeClosetItem(item: item)
        }
        cell.setup(mode: .items)
        cell.showDeleteButton = viewModel.viewMode.value == .edit ? true : false
        
        return cell
    }
}
