//
//  NewItemViewController.swift
//  Diwi
//
//  Created by Dominique Miller on 9/3/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class NewItemViewController: UIViewController,
                             UINavigationControllerDelegate {
    
    enum Direction {
        case down, right
    }
    
    // MARK: - view props
    let scrollView      = UIScrollView()
    let navHeader       = NavHeader()
    let imagePreview    = UIImageView()
    let itemTitle       = MDCTextField()
    var itemTitleController = MDCTextInputControllerUnderline()
    let itemType        = UITextField()
    let typeUnderline   = UIView()
    var itemTypeController = MDCTextInputControllerUnderline()
    let dateAddedlabel  = UILabel()
    let dateAdded       = UILabel()
    let saveItem        = AppButton()
    let arrowIcon       = UIImageView()
    let closetIcon      = UIImageView()
    let lookItems       = HeaderSectionsForCollectionViews.closet(TextContent.Labels.looks).view()
    let whereIWoreIt    = HeaderSectionsForCollectionViews.events(TextContent.Labels.whereIWoreIt).view()
    let whenIWoreIt     = HeaderSectionsForCollectionViews.dates(TextContent.Labels.whenIworeIt).view()
    let whoIWoreItWith  = HeaderSectionsForCollectionViews.contacts(TextContent.Labels.whoIWoreItWith).view()
    let note            = UITextView()
    let dateLabel       = UILabel()
    var spinnerView     = UIView()
    let mediaChoice     = TwoButtonModal(topBtnText: TextContent.Alert.camera,
                                         bottomBtnText: TextContent.Alert.photoLibrary)
    
    // MARK: - internal props
    let disposeBag = DisposeBag()
    weak var coordinator: MainCoordinator?
    var viewModel: NewItemViewModel!
    var goBack: (() -> Void)?
    var addClosetItems: ((_ items: [ModelDefault]) -> Void)?
    var addEvents: ((_ items: [ModelDefault]) -> Void)?
    var addDates: (() -> Void)?
    var addContacts: (() -> Void)?
    var goToSearch: (() -> Void)?
    var finished: (()-> Void)?
    var itemTypesPicker = UIPickerView()
    var pickerToolbar = UIToolbar()
    var itemTypes = [String]()
    var mediaChoiceWasShown = false
    var scrollContainerBottomConstraint: NSLayoutConstraint?
    var closetCollectionView: UICollectionView!
    var closetCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    var eventCollectionView: UICollectionView!
    var eventCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    var datesCollectionView: UICollectionView!
    var datesCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    var contactsCollectionView: UICollectionView!
    var contactsCollectionViewHeight: NSLayoutConstraint = NSLayoutConstraint()

    override func viewDidLoad() {
       super.viewDidLoad()
        
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
        
        if let items = coord.selectedItemsForNewClosetItem as? [Look],
            items.count > 0 {
           viewModel.updateLooks(with: items)
        }
        
        if coord.selectedEvents.count > 0 {
            viewModel.updateEvents(with: coord.selectedEvents)
        }
        
        if let newDate = coord.selectedDate {
            viewModel.updateDates(with: newDate)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !mediaChoiceWasShown {
          showMediaChoiceModal()
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

// MARK: - Select media type
extension NewItemViewController {
    private func verifyCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: setupCaptureSession(media: .camera)
        case .notDetermined: verifyAuthForCamera()
        case .denied: return
        case .restricted: return
        }
    }
    
    private func verifyAuthForCamera() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.setupCaptureSession(media: .camera)
                }
            }
        }
    }
    
    private func verifyPhotoLibraryAccess() {
        let authorization = PHPhotoLibrary.authorizationStatus()
        switch authorization {
        case .authorized: setupCaptureSession(media: .photoLibrary)
        case .notDetermined: requestAuthForLibrary()
        case .denied: return
        case .restricted: return
		case .limited: return
        }
    }
    
    private func requestAuthForLibrary() {
        PHPhotoLibrary.requestAuthorization({status in
            if status == .authorized{
                DispatchQueue.main.async {
                    self.setupCaptureSession(media: .photoLibrary)
                }
            }
        })
    }
}

// MARK: - UIImagePickerController
extension NewItemViewController: UIImagePickerControllerDelegate {
    private func setupCaptureSession(media: UIImagePickerController.SourceType) {
        let vc = UIImagePickerController()
        vc.sourceType = media
        vc.allowsEditing = true
        vc.delegate = self
        
        mediaChoiceWasShown = true
        
        present(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            self.mediaChoiceWasShown = false
            self.showMediaChoiceModal()
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: {
            self.setupView()
            self.setupBindings()
        })
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        viewModel.formatDatePhotoTaken(for: Date())
        viewModel.itemPhoto.accept(image)
    }
}

// MARK: - Setup view
extension NewItemViewController: UITextFieldDelegate {
    private func setupView() {
        view.backgroundColor = UIColor.white
        
        setupHeader()
        setupScroll()
        setupImagePreview()
        setupItemTypesPicker()
        setupPickerToolbar()
        setupItemType()
        setupWhereIWentView()
        setupEventCollectionView()
        setupWhenIWentView()
        setupDatesCollectionView()
        setupwhoIWoreItWith()
        setupContactsCollectionView()
        setupWhatIWoreView()
        setupClosetCollectionView()
        setupNote()
        setupDateAdded()
        setupSaveItem()
        setupSpinner()
    }
    
    private func setupHeader() {
        navHeader.translatesAutoresizingMaskIntoConstraints = false
        navHeader.setup(backgroundColor: UIColor.Diwi.barney,
                        style: .normal,
                        navTitle: TextContent.Labels.myItem)
        
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
    
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollContainerBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollView.addGestureRecognizer(tap)
        
        view.addSubview(scrollView)
        
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
    
    private func setupImagePreview() {
        imagePreview.translatesAutoresizingMaskIntoConstraints = false
        imagePreview.backgroundColor = .gray
        imagePreview.contentMode = .scaleAspectFill
        
        scrollView.addSubview(imagePreview)
        
        NSLayoutConstraint.activate([
            imagePreview.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imagePreview.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            imagePreview.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            imagePreview.heightAnchor.constraint(equalToConstant: 500),
            imagePreview.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
    }
    
    private func setupItemTypesPicker() {
        itemTypesPicker.layer.backgroundColor = UIColor.white.cgColor
        itemTypesPicker.delegate = self
        itemTypesPicker.dataSource = self
    }
    
    private func setupPickerToolbar() {
        pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(sender:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        pickerToolbar.setItems([flexibleSpace,flexibleSpace, doneButton], animated: true)
    }
    
    @objc func doneButtonPressed(sender: UIBarButtonItem) {
       itemType.resignFirstResponder()
       viewModel.validateForm()
    }
    
    private func setupItemType() {
        itemType.translatesAutoresizingMaskIntoConstraints = false
        itemType.font = UIFont.Diwi.textField
        itemType.textColor = UIColor.Diwi.darkGray
        itemType.delegate = self
        itemType.inputAccessoryView = pickerToolbar
        itemType.inputView = itemTypesPicker
        
        closetIcon.frame = CGRect(x: 10, y: 0, width: 22, height: 16)
        closetIcon.image = UIImage.Diwi.pinkHanger
        itemType.rightView = closetIcon
        itemType.rightViewMode = .always
        
        scrollView.addSubview(itemType)
        
        NSLayoutConstraint.activate([
            itemType.topAnchor.constraint(equalTo: imagePreview.bottomAnchor, constant: 35),
            itemType.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 30),
            itemType.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -30),
            ])
        
        typeUnderline.translatesAutoresizingMaskIntoConstraints = false
        typeUnderline.backgroundColor = UIColor.Diwi.azure
        
        scrollView.addSubview(typeUnderline)
        
        NSLayoutConstraint.activate([
            typeUnderline.topAnchor.constraint(equalTo: itemType.bottomAnchor, constant: 10),
            typeUnderline.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            typeUnderline.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            typeUnderline.heightAnchor.constraint(equalToConstant: 1)
            ])
    }
    
    private func setupWhereIWentView() {
           scrollView.addSubview(whereIWoreIt)

           NSLayoutConstraint.activate([
              whereIWoreIt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
              whereIWoreIt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
              whereIWoreIt.topAnchor.constraint(equalTo: typeUnderline.bottomAnchor, constant: 20),
              whereIWoreIt.heightAnchor.constraint(equalToConstant: 28),
           ])
       }
       
    private func setupEventCollectionView() {
        eventCollectionView = CollectionsConfig.events.collectionView()
        eventCollectionView.delegate = self
        eventCollectionView.dataSource = self
        
        scrollView.addSubview(eventCollectionView)

        eventCollectionViewHeight = eventCollectionView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            eventCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            eventCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            eventCollectionView.topAnchor.constraint(equalTo: whereIWoreIt.bottomAnchor, constant: 10),
            eventCollectionViewHeight,
        ])

    }
       
    private func setupWhenIWentView() {
        scrollView.addSubview(whenIWoreIt)

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
               
            scrollView.addSubview(datesCollectionView)
        
            datesCollectionViewHeight = datesCollectionView.heightAnchor.constraint(equalToConstant: 0)
        
            NSLayoutConstraint.activate([
                datesCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
                datesCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
                datesCollectionView.topAnchor.constraint(equalTo: whenIWoreIt.bottomAnchor, constant: 10),
                datesCollectionViewHeight,
            ])

    }
       
       private func setupwhoIWoreItWith() {
           scrollView.addSubview(whoIWoreItWith)

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
           
           scrollView.addSubview(contactsCollectionView)

           contactsCollectionViewHeight = contactsCollectionView.heightAnchor.constraint(equalToConstant: 0)

           NSLayoutConstraint.activate([
               contactsCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
               contactsCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
               contactsCollectionView.topAnchor.constraint(equalTo: whoIWoreItWith.bottomAnchor, constant: 10),
               contactsCollectionViewHeight,
           ])
       }
       
       private func setupWhatIWoreView() {
           scrollView.addSubview(lookItems)

           NSLayoutConstraint.activate([
              lookItems.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
              lookItems.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
              lookItems.topAnchor.constraint(equalTo: contactsCollectionView.bottomAnchor, constant: 20),
              lookItems.heightAnchor.constraint(equalToConstant: 28),
           ])
       }
       
       private func setupClosetCollectionView() {
           closetCollectionView = CollectionsConfig.closet.collectionView()
           closetCollectionView.dataSource = self
           closetCollectionView.delegate = self
           
           scrollView.addSubview(closetCollectionView!)

           closetCollectionViewHeight = closetCollectionView.heightAnchor.constraint(equalToConstant:0)
           NSLayoutConstraint.activate([
               closetCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
               closetCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
               closetCollectionView.topAnchor.constraint(equalTo: lookItems.bottomAnchor, constant: 10),
               closetCollectionViewHeight,
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
           
           scrollView.addSubview(note)
           
           NSLayoutConstraint.activate([
               note.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 30),
               note.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -30),
               note.heightAnchor.constraint(equalToConstant: 178),
               note.topAnchor.constraint(equalTo: closetCollectionView.bottomAnchor, constant: 30)
           ])
           
       }
    
    private func setupDateAdded() {
        dateAddedlabel.translatesAutoresizingMaskIntoConstraints = false
        dateAddedlabel.font = UIFont.Diwi.textField
        dateAddedlabel.textColor = UIColor.Diwi.azure
        dateAddedlabel.text = TextContent.Labels.dateAdded
        
        scrollView.addSubview(dateAddedlabel)
        
        NSLayoutConstraint.activate([
            dateAddedlabel.topAnchor.constraint(equalTo: note.bottomAnchor, constant: 35),
            dateAddedlabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 31),
            dateAddedlabel.heightAnchor.constraint(equalToConstant: 17)
            ])
        
        dateAdded.translatesAutoresizingMaskIntoConstraints = false
        dateAdded.font = UIFont.Diwi.textField
        dateAdded.textColor = UIColor.Diwi.brownishGrey
        
        scrollView.addSubview(dateAdded)
        
        NSLayoutConstraint.activate([
            dateAdded.topAnchor.constraint(equalTo: note.bottomAnchor, constant: 35),
            dateAdded.leftAnchor.constraint(equalTo: dateAddedlabel.rightAnchor, constant: 6),
            dateAdded.heightAnchor.constraint(equalToConstant: 17)
            ])
    }
    
    private func setupSaveItem() {
        saveItem.translatesAutoresizingMaskIntoConstraints = false
        saveItem.setTitle(TextContent.Buttons.saveItem, for: .normal)
        saveItem.titleLabel?.font = UIFont.Diwi.button
        saveItem.disableButton()
        
        scrollView.addSubview(saveItem)
        
        NSLayoutConstraint.activate([
            saveItem.topAnchor.constraint(equalTo: dateAddedlabel.bottomAnchor, constant: 35),
            saveItem.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 31),
            saveItem.heightAnchor.constraint(equalToConstant: 50),
            saveItem.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -31),
            saveItem.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -37)
            ])
    }
    
    private func setupSpinner() {
        spinnerView = UIView.init(frame: view.bounds)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.isEmpty, textField == itemType {
            textField.text = itemTypes[0]
        } else {
            return false
        }
        
        return true
    }
    
    private func showMediaChoiceModal() {
        mediaChoice.translatesAutoresizingMaskIntoConstraints = false
        
        mediaChoice.finished = { [weak self] in
            self?.coordinator?.popController()
        }
        
        mediaChoice.topBtnPressed = { [weak self] in
            self?.hideMediaChoiceModal()
            self?.verifyCameraAuthorization()
        }
        
        mediaChoice.bottomBtnPressed = { [weak self] in
            self?.hideMediaChoiceModal()
            self?.verifyPhotoLibraryAccess()
        }
        
        view.addSubview(mediaChoice)
        
        NSLayoutConstraint.activate([
            mediaChoice.topAnchor.constraint(equalTo: view.topAnchor),
            mediaChoice.leftAnchor.constraint(equalTo: view.leftAnchor),
            mediaChoice.rightAnchor.constraint(equalTo: view.rightAnchor),
            mediaChoice.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func hideMediaChoiceModal() {
        mediaChoice.removeFromSuperview()
    }
}

// MARK: - Collection View delagate methods
extension NewItemViewController: UICollectionViewDelegate,
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
        switch collectionView {
        case eventCollectionView:
            return viewModel.eventsCount()
        case datesCollectionView:
            return viewModel.datesCount()
        case closetCollectionView:
            return viewModel.looksCount()
        case contactsCollectionView:
            return viewModel.contactsCount()
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
            cell.configure(with: name, id: event.id, mode: .edit)
        } else {
            cell.configure(with: TextContent.Labels.event, id: event.id, mode: .edit)
        }
        
        cell.remove = { [weak self] (name, id) in
            self?.viewModel.removeEvent(item: event)
        }
        
        return cell
    }
    
    private func setupDateCell(for indexPath: IndexPath) -> OblongCollectionViewCell {
        let cell: OblongCollectionViewCell = datesCollectionView.dequeueReusableCell(for: indexPath)
        let date = viewModel.getDate(at: indexPath.row)
        
        cell.configure(with: date, id: nil, mode: .edit)
        cell.remove = { [weak self] (name, id) in
            self?.viewModel.removeFromDates(date: date)
        }
        
        return cell
    }
    
    private func setupClosetCell(for indexPath: IndexPath) -> ClosetCell {
        let cell: ClosetCell = closetCollectionView.dequeueReusableCell(for: indexPath)
        let item = viewModel.getLook(at: indexPath.row)
        
        cell.indexItem = item
        cell.removeClosetItem = { [weak self] _ in
            self?.viewModel.removeLook(item: item)
        }
        cell.setup(mode: .items)
        cell.showDeleteButton = true
        
        return cell
    }
    
    private func setupContactCell(for indexPath: IndexPath) -> OblongCollectionViewCell {
        let cell: OblongCollectionViewCell = contactsCollectionView.dequeueReusableCell(for: indexPath)
        let contact = viewModel.getContact(at: indexPath.row)
        if let name = contact.title {
            cell.configure(with: name, id: contact.id, mode: .edit)
        }
        cell.remove = { [weak self] (name, id) in
            self?.viewModel.removeContact(contact: contact)
        }
        
        return cell
    }
}

// MARK: - UIPicker Delegate methods
extension NewItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return itemTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return itemTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        itemType.text = itemTypes[row]
    }
}

// MARK: - Rx Bindings
extension NewItemViewController {
    private func setupBindings() {
        viewModel.navTitle
            .asObservable()
            .map { $0 }
            .bind(to:self.navHeader.navTitle.rx.text)
            .disposed(by:self.disposeBag)
        
        saveItem.rx.tap.bind {
            self.saveItem.buttonPressedAnimation {
                self.viewModel.save()
            }
        }.disposed(by: disposeBag)
        
        lookItems.button.rx.tap.bind { [unowned self] in
            self.lookItems.button.buttonPressedAnimation {
                let items = self.viewModel.getAllItemsFor(.ClothingItems)
                self.addClosetItems?(items)
            }
        }.disposed(by: disposeBag)
        
        whereIWoreIt.button.rx.tap.bind { [unowned self] in
            self.whereIWoreIt.button.buttonPressedAnimation {
                let events = self.viewModel.getAllItemsFor(.Events)
                self.addEvents?(events)
            }
        }.disposed(by: disposeBag)
        
        whenIWoreIt.button.rx.tap.bind { [unowned self] in
            self.whenIWoreIt.button.buttonPressedAnimation {
                self.addDates?()
            }
        }.disposed(by: disposeBag)
        
        whoIWoreItWith.button.rx.tap.bind { [unowned self] in
            self.whoIWoreItWith.button.buttonPressedAnimation {
                self.addContacts?()
            }
        }.disposed(by: disposeBag)
        
        viewModel.itemTypes.subscribe(onNext:{ [unowned self] value in
            if value.count > 0 {
                self.itemTypes.append(contentsOf: value)
            }
        }).disposed(by: disposeBag)
        
        viewModel.formValid
            .subscribe(onNext:{ [unowned self] value in
            if value {
                self.saveItem.enableButton()
            } else {
                self.saveItem.disableButton()
            }
        }).disposed(by: disposeBag)
        
        viewModel.errorMsg
            .subscribe(onNext: { [unowned self] value in
                if !value.isEmpty {
                    self.presentError(value)
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [unowned self] value in
                if value {
                    self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
                }
                else {
                    self.removeSpinner(spinner: self.spinnerView)
                }
            }).disposed(by: disposeBag)
        
        viewModel.success
            .subscribe(onNext: { [unowned self] value in
                if value && self.viewModel.getCurrentWorkflow() == .addEvent {
                    self.finished?()
                } else if value && self.viewModel.getCurrentWorkflow() == .editFriend {
                    self.finished?()
                } else if value {
                    self.goBack?()
                }
            }).disposed(by: disposeBag)
        
        viewModel.savedClothingItem
            .subscribe(onNext: { [unowned self] (value: ClothingItem) in
                if value.id != nil {
                    // set returned cothing item from API to coordinator
                    // to be passed to the next route
                    self.coordinator?.clothingItem = value
                }
        }).disposed(by: disposeBag)
        
        viewModel.looks
            .skip(1)
            .subscribe(onNext: { [unowned self] items in
                self.setClosetCollectionViewHeight()
                self.closetCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                self.closetCollectionView.layoutIfNeeded()
                self.closetCollectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.events
            .skip(1)
            .subscribe(onNext: { [unowned self] items in
                self.setEventCollectionViewHeight()
                self.eventCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                self.eventCollectionView.layoutIfNeeded()
                self.eventCollectionView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.datesWorn
            .skip(1)
            .subscribe(onNext: { [unowned self] items in
                self.setDateCollectionViewHeight()
                self.datesCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                self.datesCollectionView.layoutIfNeeded()
                self.datesCollectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.contacts
            .skip(1)
            .subscribe(onNext: { [unowned self] items in
                self.setContactCollectionViewHeight()
                self.contactsCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                self.contactsCollectionView.layoutIfNeeded()
                self.contactsCollectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.dateAdded
            .subscribe(onNext: { [unowned self] value in
            self.dateAdded.text = value
        }).disposed(by: disposeBag)
        
        // MARK: - UITextView bindings
        note.rx.didBeginEditing.bind { [unowned self] in
            if self.note.textColor == UIColor.Diwi.fadedGray {
                self.note.text = nil
                self.note.textColor = UIColor.black
            }
        }.disposed(by: disposeBag)
        
        note.rx.didEndEditing.bind { [unowned self] in
            if self.note.text.isEmpty {
                self.note.text = TextContent.Labels.addANote
                self.note.textColor = UIColor.lightGray
            }
            self.note.resignFirstResponder()
        }.disposed(by: disposeBag)
        
        itemType.rx
            .controlEvent([.editingDidBegin, .editingDidEnd])
            .bind { [unowned self] in
                self.viewModel.validateForm()
        }.disposed(by: disposeBag)
        
        itemTitle.rx.text.orEmpty
            .bind(to: viewModel.itemTitle)
            .disposed(by: disposeBag)
        
        itemType.rx.text.orEmpty
            .bind(to: viewModel.itemType)
            .disposed(by: disposeBag)
        
        viewModel.itemPhoto
            .bind(to: imagePreview.rx.image)
            .disposed(by: disposeBag)
        
        note.rx.text.orEmpty
            .bind(to: viewModel.note)
            .disposed(by: disposeBag)
    }
}
