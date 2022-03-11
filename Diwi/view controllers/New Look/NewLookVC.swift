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
import YPImagePicker
//import AssetsPickerViewController
import AVFoundation
import Photos
import PhotosUI
import AVKit


class NewLookVC: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableVw: UITableView!
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var camBtn: UIButton!
    @IBOutlet weak var diwiPageControll: UIPageControl!
    var selectedImages: [UIImage]!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    let collectionViewFlowLayout = SnapCenterLayout()
    var lookImages: [UIImage] = []
    var friendsAdded: [String] = []
    private var currentImageIndex = 0
    var newLook: NewLook = NewLook()
    var isFreshPost: Bool = true
    var selectedFriendsModel = [FriendModel]()
    var images = [UIImage]()
    var bookmarkIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar(isEditingLook: false)
        setupCollectionView()
        deleteBtn.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
        bookmarkBtn.addTarget(self, action: #selector(bookmarkBtnTapped), for: .touchUpInside)
        camBtn.addTarget(self, action: #selector(camBtnTapped), for: .touchUpInside)
        self.diwiPageControll.numberOfPages = 0
        self.tableVw.reloadData()
    }
    
    @objc func camBtnTapped(_ sender: UIButton) {
        if self.images.count < 10
        {
            presentAssetPicker()
//            presentImagePickerController()
        }else
        {
            AlertController.alert(message: AlertMsg.lookImageExceedMessage)
        }
    }
    @objc func bookmarkBtnTapped(_ sender: UIButton) {
        bookmarkIndex = currentImageIndex
    }
    
    
    @objc func deleteBtnTapped(_ sender: UIButton) {
        AlertController.actionSheetWithDestructive(title: "", message: "Delete Photo?", sourceView: self.view, buttons: [], destructiveButtonTitle: "Delete Photo", cancelButtonTitle: "Cancel") { (actionsheet, selectedIndex) in
            self.view.endEditing(true)
            if selectedIndex == 1 {
                if self.currentImageIndex < self.images.count {
                    self.images.remove(at: self.currentImageIndex)
                    self.currentImageIndex -= 1
                    self.diwiPageControll.numberOfPages = self.images.count
                    self.collectionView.reloadData()
                    
                    if self.currentImageIndex == self.bookmarkIndex{
                        self.bookmarkIndex = -1
                    }else if self.currentImageIndex < self.bookmarkIndex{
                        self.bookmarkIndex -= 1
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
//        presentImagePickerController()
//        setupNavBar(isEditingLook: false)
        self.navigationController?.isNavigationBarHidden = false
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //        addfriends.removeAll()
//        self.dismiss(animated: true, completion: nil)

    }

    func setupNavBar(isEditingLook : Bool) {
        configureNavigationBar(largeTitleColor: .white,
                               backgoundColor: UIColor.Diwi.barney,
                               tintColor: .white, title: "New Look",
                               preferredLargeTitle: false,
                               searchController: nil)


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
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Diwi.navigationButton]

    }

    @objc func leftBarButtonTapped() {
        AlertController.actionSheetWithDestructive(title: "", message: "Do you want to discard this post?", sourceView: self.view, buttons: [], destructiveButtonTitle: "Discard", cancelButtonTitle: "Cancel") { (actionsheet, selectedIndex) in
            self.view.endEditing(true)
            if selectedIndex == 1 {
                self.resetFields()
                self.dismiss(animated: true, completion: nil)

            }
        }
    }

    func resetFields()  {
        isFreshPost = true
        self.images = []
        self.newLook = NewLook()
        self.diwiPageControll.numberOfPages = 0
        self.friendsAdded.removeAll()
        self.newLook.tagIds.removeAll()
//        self.imagePickerController.stack.resetAssets([])
        for i in 0...(self.friendsAdded.isEmpty ? 5 : 6)
        {
            let indexPath = IndexPath(row: i, section: 0)
            if let cell = self.tableVw.cellForRow(at: indexPath) as? TextfieldWithIconTableViewCell
            {
                if cell.textField.placeholder == "Select Date"
                {
                    cell.datePicker.setDate(Date(), animated: false)
                    self.newLook.datesWorn.removeAll()
                    self.newLook.datesWorn.append(cell.datePicker.date.toString("MM/dd/yyyy"))
                    cell.textField.text = self.newLook.datesWorn.first ?? ""
                }
                else
                {
                    cell.textField.placeholder = "Enter Location"
                    cell.textField.text = ""
                }
            }else if let cell = self.tableVw.cellForRow(at: indexPath) as? FriendsTableViewCell
            {
                cell.iconView.image = #imageLiteral(resourceName: "friendsIcon")
                cell.configureCell(self.friendsAdded, self)
            }else if let cell = self.tableVw.cellForRow(at: indexPath) as? GrowingTextfieldTableViewCell
            {
                cell.diwiTextView.text = ""
            }else if let cell = self.tableVw.cellForRow(at: indexPath) as? LooktTitleTableViewCell
            {
                cell.titleLabelTextfield.text = ""
            }
        }
        NotificationCenter.default.post(name: Notification.Name(lookAddedString), object: nil, userInfo: nil)
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.selectedIndex = 1
        self.tableVw.reloadData()
        self.collectionView.reloadData()
    }

    @objc func rightBarButtonTapped() {
        // Func to save data
        self.view.endEditing(true)
        if validData() {
            Loader.show()
            for img in images {
                let imageData : Data = img.highestQualityJPEGNSData
                let imageBase64String : String = imageData.base64EncodedString()
                newLook.photos.append("data:image/png;base64,"+imageBase64String)
            }

            let dictionary = newLook.toDictionary()
            APIManager.addNewLook(parameters: dictionary) { (success, error) in
                Loader.hide()
                if let success = success, success {
                    self.resetFields()
                    let look = LooksViewController()
                    self.navigationController?.pushViewController(look, animated: true)

                    
//                    let newViewController = LooksViewController()
//                    self.navigationController?.pushViewController(newViewController, animated: true)
//                    newViewController.modalPresentationStyle = .fullScreen

//                    self.presentingViewController?.dismiss(animated: true, completion: nil)

                   
                } else {
                    AlertController.alert(message: AlertMsg.errorCreateLook)
                }
            }
        }
    }

    func validData() -> Bool {
        if images.isEmpty {
            AlertController.alert(message: AlertMsg.selectImg)
            return false
        } else if newLook.title.isEmpty {
            AlertController.alert(message: AlertMsg.addTitle)
            return false
        }
                else if newLook.location.isEmpty {
                    AlertController.alert(message: AlertMsg.addLocation)
                    return false
                }
        
        else if newLook.datesWorn.isEmpty {
            AlertController.alert(message: AlertMsg.selectdate)
            return false
        }
        
        else
        {
            return true
        }
        
    }
}

extension NewLookVC: AssetsPickerViewControllerDelegate{




    func presentAssetPicker(){

        let picker = AssetsPickerViewController()

        picker.pickerDelegate = self
        present(picker, animated: true, completion: nil)
//        dismiss(animated: false, completion: nil)
        

    }
    
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        
        
    }
    
    
    func assetsPickerDidCancel(controller: AssetsPickerViewController) {
        
        
    }
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        print(assets)
        print(assets[0])
        for asset in assets {
            _ = getAssetThumbnail(asset: asset)
        }


//        self.images = assets as? [UIImage] ?? []
//        print(self.images)
//        print(assets[0].mediaSubtypes)
//        print(assets[0].sourceType)
//        self.setupView()
    }

   

    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        manager.requestImage(for: asset, targetSize: CGSize(width: 400, height: 500), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            if let result = result{
                thumbnail = result
            }
            print(thumbnail)
            self.images.append(thumbnail)
            print(self.images)
            self.collectionView.reloadData()
        })
        return thumbnail
    }

}

   


extension NewLookVC: FreindsTableViewCellDelegate,FriendsAddedDelegate {
    
    func updateFriends(_ friends: [String],index: Int, lookingPosts: Bool) {
        
        let deletedValue = friendsAdded[index]
        let deletedItem = selectedFriendsModel.filter {$0.title == deletedValue}
        if deletedItem.count > 0
        {
            let idIndex = deletedItem[0].id
            if let indexID = newLook.tagIds.firstIndex(of: idIndex ?? 0) {
                newLook.tagIds.remove(at: indexID)
            }
            friendsAdded = friends
        }
        friendsAdded = friendsAdded.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        if friendsAdded.isEmpty {
            self.tableVw.reloadData()
        }
    }
    
    
    func selectedFriends(ids: [Int],names: [String], resource: [FriendModel]) {
        selectedFriendsModel = resource
        friendsAdded = names
        newLook.tagIds = ids
        friendsAdded = friendsAdded.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
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

 //MARK: -  ImagePickerViewController
//extension NewLookVC: ImagePickerDelegate {
//
//    func presentImagePickerController() {
//        let imagePickerController = ImagePickerController()
//        imagePickerController.imageLimit = 10 - images.count
//        imagePickerController.delegate = self
//
//        imagePickerController.modalPresentationStyle = .overFullScreen
//        present(imagePickerController, animated: true, completion: nil)
//    }
//
//    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        print("WrapperDidPress was called...")
//    }
//
//    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        imagePicker.dismiss(animated: true, completion: nil)
//        isFreshPost = false
//        if imagePicker.isTakingPicture
//        {
//            imagePicker.isTakingPicture = false
//            presentModal(images: images)
//        }else
//        {
//            self.images.append(contentsOf: images)
//            self.diwiPageControll.numberOfPages = self.images.count
//            self.collectionView.reloadData()
//        }
//    }
//
//    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
//        imagePicker.dismiss(animated: true, completion: nil)
//        if isFreshPost
//        {
//            self.tabBarController?.tabBar.isHidden = false
//            self.tabBarController?.selectedIndex = 1
//        }
//    }
//
//    func presentModal(images: [UIImage]) {
//        let vc = UIStoryboard.init(name: "Preview", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
//        vc.images = images
//        vc.callback = { bool in
//            if bool ?? false
//            {
//                vc.navigationController?.popViewController(animated: false)
//                self.images.append(contentsOf: images)
//                self.diwiPageControll.numberOfPages = self.lookImages.count
//                self.navigationController?.removeViewController(ImagePickerController.self)
//                self.collectionView.reloadData()
//            } else {
//                vc.navigationController?.popViewController(animated: false)
//            }
//        }
//        self.navigationController?.pushViewController(vc, animated: false)
//    }
//}



extension NewLookVC: UITableViewDelegate,UITableViewDataSource {
    
    /// To manage empty friends cell
    func getCellRenderIndex(_ indexPath: IndexPath) -> Int {
        return friendsAdded.isEmpty ? indexPath.row >= 3 ? indexPath.row + 1 : indexPath.row : indexPath.row
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsAdded.isEmpty ? 5 : 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        let cellIndex = getCellRenderIndex(indexPath)
        switch cellIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: LooktTitleTableViewCell.identifier, for: indexPath) as! LooktTitleTableViewCell
            cell.configure(self, newLook)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextfieldWithIconTableViewCell.identifier, for: indexPath) as! TextfieldWithIconTableViewCell
            cell.configureCell(#imageLiteral(resourceName: "location-1"), self, newLook, false)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextfieldWithIconTableViewCell.identifier, for: indexPath) as! TextfieldWithIconTableViewCell
            cell.configureCell(#imageLiteral(resourceName: "calendarIconGray"), self, newLook, true)
//            cell.datePicker.minimumDate = Date()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: FriendsTableViewCell.identifier, for: indexPath) as! FriendsTableViewCell
            cell.iconView.image = #imageLiteral(resourceName: "friendsIcon")
            cell.configureCell(friendsAdded, self)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddFriendsTableViewCell.identifier, for: indexPath) as! AddFriendsTableViewCell
            cell.iconView.image = friendsAdded.isEmpty ? #imageLiteral(resourceName: "friendsIcon") : nil
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: GrowingTextfieldTableViewCell.identifier, for: indexPath) as! GrowingTextfieldTableViewCell
            cell.configure(self, newLook)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: LooktTitleTableViewCell.identifier, for: indexPath) as! LooktTitleTableViewCell
            cell.titleLabelTextfield.text = ""
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellIndex = getCellRenderIndex(indexPath)
        switch cellIndex {
        case 5:
            return 130
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellIndex = getCellRenderIndex(indexPath)
        if cellIndex == 4 {
            goToFriends()
        }
    }
}

extension NewLookVC: UICollectionViewDelegate,UICollectionViewDataSource {
    
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
        return images.count //lookImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LookHeaderCollectionViewCell", for: indexPath) as! LookHeaderCollectionViewCell
        if images != nil  {
            self.diwiPageControll.numberOfPages = self.images.count
            cell.backgroundImage.image = images[indexPath.row]
        } else {
            cell.backgroundImage.image = #imageLiteral(resourceName: "sample_image")
        }
//        cell.playVideo(videoUrl: "http://3.143.193.45/fpw.mp4" )
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
}

extension NewLookVC: TextFieldCellDelegate, LookTitleCellDelegate, GrowingTextFieldDelegate {
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
