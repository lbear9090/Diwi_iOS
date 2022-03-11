//
//  NewLookVC.swift
//  Diwi
//
//  Created by Nitin Agnihotri on 13/01/21.
//  Copyright © 2021 Trim Agency. All rights reserved.
//

import UIKit
import ImagePicker
import IQKeyboardManager

class LookDetailVC: UIViewController, UINavigationControllerDelegate, LightboxControllerPageDelegate {
    
    @IBOutlet weak var tableVw: UITableView!
    @IBOutlet weak var diwiPageControll: UIPageControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var camBtn: UIButton!
    
    let collectionViewFlowLayout = SnapCenterLayout()
    var lookImages: [Any] = []
    var friendsAdded: [String] = []
    var tableCellType: [String] = []
    var lookID = String()
    var newLook: NewLook = NewLook()
    var completeLookDetail: Look = Look()
    var selectedImages: [UIImage]!
    var isEditingLook: Bool = false
    var showFriendDelete: Bool = false
    var showFieldsBorder: Bool = false
    var numberOfRows: Int = 0
    var lookPhotos: [LookPhotos]?
    
    private var currentImageIndex = 0
    private var originalLook: Look?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
        
        deleteBtn.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
        camBtn.addTarget(self, action: #selector(camBtnTapped), for: .touchUpInside)
        
        self.diwiPageControll.numberOfPages = 0
        
        self.fetchLookDetail()
        
    }
    
    func fetchLookDetail() {
        Loader.show()
        APIManager.fetchLookDetail(url: "\(ApiURL.fetchLooks)/" + "\(lookID)", comp: { (lookDetail,look,error) in
            Loader.hide()
            if error == nil
            {
                debugPrint(lookDetail?.title ?? "")
                if lookDetail != nil
                {
                    self.newLook = lookDetail!
                    self.completeLookDetail = look!
                    self.friendsAdded = look?.tags?.compactMap{ $0.title} ?? []
                    self.friendsAdded = self.friendsAdded.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                    self.newLook.tagIds = look?.tags?.compactMap{ $0.id} ?? []
                    self.lookImages = look?.lookPhotos?.compactMap{ $0.image} ?? []
                    self.lookImages.reverse()
                    self.lookPhotos = look?.lookPhotos
                    self.diwiPageControll.numberOfPages = self.lookImages.count
                    self.layoutTableHeaderView()
                    self.updateCellArray()
                    self.tableVw.reloadData()
                    self.collectionView.reloadData()
                }
            }else
            {
                AlertController.alert(message: error ?? AlertMsg.errorCreateLook)
            }
        })
    }
    
    func updateCellArray()  {
        tableCellType = ["title","location","date"]
        if !self.friendsAdded.isEmpty
        {
            tableCellType.append("friends")
        }
        if self.isEditingLook
        {
            tableCellType.append("addFriends")
            if newLook.note.count == 0
            {
                tableCellType.append("note")
            }
        }
        if newLook.note.count > 0
        {
            if !tableCellType.contains("")
            {
                tableCellType.append("note")
            }
        }
    }
    
    func layoutTableHeaderView() {

        guard let headerView = self.tableVw.tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        var frame = headerView.frame
        frame.size.height = self.lookImages.count == 1 ? 510 : 540
        headerView.frame = frame

        self.tableVw.tableHeaderView = headerView
        headerView.translatesAutoresizingMaskIntoConstraints = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //        addfriends.removeAll()
    }
    
    @objc func camBtnTapped(_ sender: UIButton) {
        if self.lookImages.count < 10
        {
            presentImagePickerController()
        }else
        {
            AlertController.alert(message: AlertMsg.lookImageExceedMessage)
        }
    }
    
    @objc func deleteBtnTapped(_ sender: UIButton) {
        AlertController.actionSheetWithDestructive(title: "", message: "Delete Photo?", sourceView: self.view, buttons: [], destructiveButtonTitle: "Delete Photo", cancelButtonTitle: "Cancel") { (actionsheet, selectedIndex) in
            self.view.endEditing(true)
            if selectedIndex == 1 {
                if self.currentImageIndex < self.lookImages.count {
                    if self.lookImages[self.currentImageIndex] is String
                    {
                        let imageURL = self.lookImages[self.currentImageIndex] as! String
                        let b = self.lookPhotos?.filter {$0.image == imageURL}
                        if b?.count ?? 0 > 0
                        {
                            self.newLook.imageIdsToBeDeleted.append((b?[0].id!)!)
                            if let index = self.lookPhotos?.index(where: {$0.image == imageURL}) {
                                self.lookPhotos?.remove(at: index)
                            }
                        }
                    }
                    self.lookImages.remove(at: self.currentImageIndex)
                    self.currentImageIndex -= 1
                    self.diwiPageControll.numberOfPages = self.lookImages.count
                    self.updateCellArray()
                    self.layoutTableHeaderView()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    private func setupNavBar() {
        configureNavigationBar(largeTitleColor: .white,backgoundColor: UIColor.Diwi.barney,tintColor: .white, title: isEditingLook ? "Edit Look" : "Look",preferredLargeTitle: false,searchController: nil)
        
        if isEditingLook
        {
            let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(title:"Cancel",
                                                                     style: .plain,
                                                                     target: self,
                                                                     action:#selector(leftBarButtonTapped))
            
            let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title:"Save",
                                                                      style: .plain,
                                                                      target: self,
                                                                      action:#selector(rightBarButtonTapped))
            
            self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
            self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
            
        }else
        {
            let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
            button.setImage(UIImage(named: "navigateDotsMenu"), for: .normal)
            button.addTarget(self, action: #selector(LookDetailVC.fbButtonPressed), for: .touchUpInside)
            let newFrame = CGRect(x: 0,y: 0,width: 40,height: 50)
            button.frame = newFrame
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
            self.navigationItem.leftBarButtonItem = nil
            
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Diwi.navigationButton]
    }
    
    @objc func leftBarButtonTapped() {
        self.deleteBtn.isHidden = true
        self.camBtn.isHidden = true
        self.isEditingLook = false
        self.showFriendDelete = false
        self.showFieldsBorder = false
        self.setupNavBar()
        self.friendsAdded = self.completeLookDetail.tags?.compactMap{ $0.title} ?? []
        self.newLook.tagIds = self.completeLookDetail.tags?.compactMap{ $0.id} ?? []
        self.lookImages = self.completeLookDetail.lookPhotos?.compactMap{ $0.image} ?? []
        self.lookImages.reverse()
        self.lookPhotos = self.completeLookDetail.lookPhotos
        self.diwiPageControll.numberOfPages = self.lookImages.count
        self.updateCellArray()
        self.tableVw.reloadData()
        self.collectionView.reloadData()
    }
    
    @objc func fbButtonPressed() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler:{(alert: UIAlertAction!) -> Void in
            AlertController.alert(title: "Alert", message: "Are you sure you want to delete this look?", buttons: ["Cancel","Delete"]) { (alert, success) in
                if success == 1
                {
                    self.deleteLook()
                }
            }
        })
        
        let saveAction = UIAlertAction(title: "Edit", style: .default, handler:{(alert: UIAlertAction!) -> Void in
            self.isEditingLook = true
            self.showFriendDelete = true
            self.showFieldsBorder = true
            self.deleteBtn.isHidden = false
            self.camBtn.isHidden = false
            self.updateCellArray()
            self.tableVw.reloadData()
            self.collectionView.reloadData()
            self.setupNavBar()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{(alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func deleteLook() {
        Loader.show()
        APIManager.deleteLook(url: "\(ApiURL.fetchLooks)/" + "\(lookID)", comp: { (success,error) in
            Loader.hide()
            if success ?? false
            {
                NotificationCenter.default.post(name: Notification.Name(lookAddedString), object: nil, userInfo: nil)
                AlertController.alert(title: "", message: error ?? "Deleted successfully", acceptMessage: "Ok") {
                    self.navigationController?.popViewController(animated: true)
                }
            }else
            {
                AlertController.alert(message: error ?? AlertMsg.errorCreateLook)
            }
        })
    }
    
    
    @objc func rightBarButtonTapped() {
        self.view.endEditing(true)
        if validData() {
            Loader.show()
            for img in lookImages {
                if img is UIImage
                {
                    let imageData : Data = (img as! UIImage).lowestQualityJPEGNSData
                    if let imageBase64String = imageData.base64EncodedString() as? String {
                        newLook.photos.append("data:image/png;base64,"+imageBase64String)
                    }
                }
            }
            let dictionary = newLook.toDictionary()
            APIManager.editLook(lookID: lookID, parameters: dictionary) { (success, error) in
                Loader.hide()
                if let success = success, success {
                    AlertController.alert(title: "", message: "Look updated successfully", acceptMessage: "Ok") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    AlertController.alert(message: AlertMsg.errorCreateLook)
                }
            }
        }
    }
    
    func validData() -> Bool {
        if lookImages.isEmpty {
            AlertController.alert(message: AlertMsg.selectImg)
            return false
        } else if newLook.title.isEmpty {
            AlertController.alert(message: AlertMsg.addTitle)
            return false
        }
//        else if newLook.location.isEmpty {
//            AlertController.alert(message: AlertMsg.addLocation)
//            return false
//        }
        else
        {
            return true
        }
    }
}

extension LookDetailVC: FreindsTableViewCellDelegate,FriendsAddedDelegate {
    
    func updateFriends(_ friends: [String],index: Int, lookingPosts: Bool) {
        if lookingPosts
        {
            self.tabBarController?.tabBar.isHidden = true
            let vc = FriendsLooksViewController()
            vc.friendID = friendsAdded[index]
            vc.descriptionText = " All Looks with \u{22}\(friendsAdded[index].capitalized)\u{22}"
            navigationController?.pushViewController(vc, animated: true)
        }else
        {
            let deletedValue = friendsAdded[index]
            let deletedItem = self.completeLookDetail.tags?.filter {$0.title == deletedValue}
            if deletedItem?.count ?? 0 > 0
            {
                let idIndex = deletedItem?[0].id
                let b = self.completeLookDetail.lookTags?.filter {$0.tagId == idIndex}
                if b?.count ?? 0 > 0
                {
                    newLook.tagsIdsToBeDeleted.append((b?[0].id)!)
                }
                if let indexID = newLook.tagIds.firstIndex(of: idIndex ?? 0) {
                    newLook.tagIds.remove(at: indexID)
                }
                friendsAdded = friends
            }
            friendsAdded = friendsAdded.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            self.updateCellArray()
            if friendsAdded.isEmpty {
                self.tableVw.reloadData()
            }
        }
    }
    
    
    func selectedFriends(ids: [Int],names: [String], resource: [FriendModel]) {
        friendsAdded = names
        newLook.tagIds = ids
        if newLook.tagIds.count > 0
        {
            for i in 0...newLook.tagIds.count - 1
            {
                let item = newLook.tagIds[i]
                let b = self.completeLookDetail.lookTags?.filter {$0.tagId == item}
                if b?.count ?? 0 > 0
                {
                    let b = newLook.tagsIdsToBeDeleted.filter {$0 == (b?[0].id)!}
                    if b.count > 0
                    {
                        newLook.tagsIdsToBeDeleted.remove(at: newLook.tagsIdsToBeDeleted.index(of: b[0]) ?? i)
                    }
                }
            }
        }
        friendsAdded = friendsAdded.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        self.updateCellArray()
        self.tableVw.reloadData()
    }
    
    func goToFriends() {
        let objFriendsList = FriendsListViewController()
        objFriendsList.delegate = self
        objFriendsList.selectedFreiends = newLook.tagIds
        objFriendsList.selectedName = friendsAdded
        let viewController = UINavigationController(rootViewController: objFriendsList)
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: true, completion: nil)
    }
}


extension LookDetailVC: UITableViewDelegate,UITableViewDataSource {
    
    /// To manage empty friends cell
    func getCellRenderIndex(_ indexPath: IndexPath) -> Int {
        return friendsAdded.isEmpty ? indexPath.row >= 3 ? indexPath.row + 1 : indexPath.row : indexPath.row
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableCellType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        let cellIndex = tableCellType[indexPath.row]//getCellRenderIndex(indexPath)
        switch cellIndex {
        case "title":
            let cell = tableView.dequeueReusableCell(withIdentifier: LooktTitleTableViewCell.identifier, for: indexPath) as! LooktTitleTableViewCell
            cell.isEdit = showFieldsBorder
            cell.configure(self, newLook)
            return cell
        case "location":
            let cell = tableView.dequeueReusableCell(withIdentifier: TextfieldWithIconTableViewCell.identifier, for: indexPath) as! TextfieldWithIconTableViewCell
            cell.isEdit = showFieldsBorder
            cell.configureCell(#imageLiteral(resourceName: "location-1"), self, newLook, false)
            return cell
        case "date":
            let cell = tableView.dequeueReusableCell(withIdentifier: TextfieldWithIconTableViewCell.identifier, for: indexPath) as! TextfieldWithIconTableViewCell
            cell.isEdit = showFieldsBorder
            cell.configureCell(#imageLiteral(resourceName: "calendarIconGray"), self, newLook, true)
            //cell.datePicker.minimumDate = Date()
            return cell
        case "friends":
            let cell = tableView.dequeueReusableCell(withIdentifier: FriendsTableViewCell.identifier, for: indexPath) as! FriendsTableViewCell
            cell.iconView.image = #imageLiteral(resourceName: "friendsIcon")
            cell.showRemoveButton = showFriendDelete
            cell.configureCell(friendsAdded, self)
            return cell
        case "addFriends":
            let cell = tableView.dequeueReusableCell(withIdentifier: AddFriendsTableViewCell.identifier, for: indexPath) as! AddFriendsTableViewCell
            cell.iconView.image = friendsAdded.isEmpty ? #imageLiteral(resourceName: "friendsIcon") : nil
            return cell
        case "note":
            let cell = tableView.dequeueReusableCell(withIdentifier: GrowingTextfieldTableViewCell.identifier, for: indexPath) as! GrowingTextfieldTableViewCell
            cell.isEdit = showFieldsBorder
            cell.configure(self, newLook)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: LooktTitleTableViewCell.identifier, for: indexPath) as! LooktTitleTableViewCell
            cell.isEdit = showFieldsBorder
            cell.titleLabelTextfield.text = ""
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableCellType.count - 1) == indexPath.row
        {
            if tableCellType[indexPath.row] == "note"
            {
                return 130
            }
            return 45
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (tableView.cellForRow(at: indexPath) as? AddFriendsTableViewCell) != nil
        {
            goToFriends()
        }
    }
}

// MARK: -  ImagePickerViewController
extension LookDetailVC: ImagePickerDelegate {

    func presentImagePickerController() {
        let imagePickerController = ImagePickerController()
        imagePickerController.imageLimit = 10 - lookImages.count
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .overFullScreen
        present(imagePickerController, animated: true, completion: nil)
    }

    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("WrapperDidPress was called...")
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if imagePicker.isTakingPicture
        {
            imagePicker.isTakingPicture = false
            presentModal(images: images)
        }else
        {
            self.lookImages.append(contentsOf: images)
            self.diwiPageControll.numberOfPages = self.lookImages.count
            self.collectionView.reloadData()
        }
        layoutTableHeaderView()
    }

    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func presentModal(images: [UIImage]) {
        let vc = UIStoryboard.init(name: "Preview", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
        vc.images = images
        vc.callback = { bool in
            if bool ?? false
            {
                vc.navigationController?.popViewController(animated: false)
                self.lookImages.append(contentsOf: images)
                self.diwiPageControll.numberOfPages = self.lookImages.count
                self.layoutTableHeaderView()
                self.navigationController?.removeViewController(ImagePickerController.self)
                self.collectionView.reloadData()
            } else {
                vc.navigationController?.popViewController(animated: false)
            }
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
}


extension LookDetailVC: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func setupCollectionView() {
        let collectionViewSize = collectionView.frame.size
        let screenSize = UIScreen.main.bounds.size
        
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.itemSize = CGSize(width: screenSize.width, height: collectionViewSize.height)
        collectionViewFlowLayout.minimumLineSpacing = 0.0
        collectionViewFlowLayout.minimumInteritemSpacing = 0.0
        
        collectionView.collectionViewLayout = collectionViewFlowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lookImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LookHeaderCollectionViewCell", for: indexPath) as! LookHeaderCollectionViewCell
        if let urlString = lookImages[indexPath.row] as? String
        {
            if let imgUrl = URL.init(string: webApiBaseURL + urlString) {
                cell.backgroundImage.sd_setShowActivityIndicatorView(true)
                cell.backgroundImage.sd_setIndicatorStyle(.gray)
                cell.backgroundImage.sd_setImage(with: imgUrl, placeholderImage: UIImage.init(named: "placeholderImage.png"), options: .highPriority) { (image, error, type, url) in
                    if error == nil {
                    }
                }
            }
        } else if let image = lookImages[indexPath.row] as? UIImage {
            cell.backgroundImage.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if diwiPageControll.currentPage == indexPath.row {
            guard let visible = collectionView.visibleCells.first else { return }
            guard let index = collectionView.indexPath(for: visible)?.row else { return }
            diwiPageControll.currentPage = index
            currentImageIndex = index
        }
    }
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        print("page: ",page)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var images = [LightboxImage]()
        for counter in 0...lookImages.count-1 {
            if let urlString = lookImages[counter] as? String {
                let lightBImg = LightboxImage(imageURL: URL(string: webApiBaseURL + urlString)!)
                images.append(lightBImg)
            }
        }
        self.presentLightBox(images: images)
    }
}

extension LookDetailVC: LightboxControllerDismissalDelegate {
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        // ...
    }
    
    private func presentLightBox(images: [LightboxImage]) {
        // Create an instance of LightboxController.
        let controller = LightboxController(images: images,startIndex: currentImageIndex)
        // Set delegates.
        controller.pageDelegate = self
        controller.dismissalDelegate = self
        
        // Use dynamic background.
        controller.dynamicBackground = true
        controller.modalPresentationStyle = .currentContext
        // Present your controller.
        present(controller, animated: true, completion: nil)
    }
}

extension LookDetailVC: TextFieldCellDelegate, LookTitleCellDelegate, GrowingTextFieldDelegate {
    func updateNotes(_ text: String) {
        newLook.note = text
    }
    
    func updateDate(_ text: String) {
        newLook.datesWorn = [text]
    }
    
    func updateLocation(_ text: String) {
        newLook.location = text
    }
    
    func updateTitle(_ text: String) {
        newLook.title = text
    }
    
}
