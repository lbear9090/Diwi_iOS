//
//  SelectedItemViewController.swift
//  Diwi
//
//  Created by Apple on 02/11/2021.
//  Copyright © 2021 Trim Agency. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons
import PhotosUI
import Kingfisher
import Foundation
import UIKit
import AVKit
//import AssetsPickerViewController



class SelectedItemViewController: UIViewController, UINavigationControllerDelegate{
    
    
    let deleteBtn = AppButton()
    let backBtn = AppButton()
    let useContent = AppButton()
    let disposeBag = DisposeBag()
    var Image = [UIImage]()
    var imageUrl = [URL]()
    var goToCamera: (() -> Void)?
    var goToNewItem: (() -> Void)?
    var goBack: (() -> Void)?
    let workflow   = BehaviorRelay<Workflow>(value: .addClosetItem)
    var images = [UIImage]()
    var blackView = UIView()
    
//    private var currentImageIndex = 0
    weak var coordinator: MainCoordinator?
    private var collectionView: UICollectionView?
    
   

    override func viewDidLoad() {
       super.viewDidLoad()
        self.presentAssetPicker()
        
            }
    

}
extension SelectedItemViewController{
    private func setupView(){
        setupBindings()
        setupCollectionView()
        setupBackBtn()
        setupUseBtn()
        
    }

    
   func setupBackBtn(){
       backBtn.translatesAutoresizingMaskIntoConstraints = false
       backBtn.setTitle(TextContent.Buttons.back, for: .normal)
       backBtn.roundAllCorners(radius: 30)
       backBtn.titleLabel?.font = UIFont.Diwi.button
       backBtn.setTitleColor(UIColor.Diwi.barney, for: .normal)
       backBtn.titleLabel?.textColor = UIColor.Diwi.barney
       backBtn.enableButton()
       backBtn.addTarget(self, action:#selector(self.CancelTap(_:)), for: .touchUpInside)
       backBtn.layer.borderWidth = 2
       backBtn.layer.borderColor = UIColor.Diwi.barney.cgColor
       backBtn.backgroundColor = .white
       view.addSubview(backBtn)
       
       NSLayoutConstraint.activate([
        backBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
        backBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
        backBtn.heightAnchor.constraint(equalToConstant: 60),
        backBtn.widthAnchor.constraint(equalToConstant: 170),
           ])
    }
    func setupUseBtn(){
        useContent.translatesAutoresizingMaskIntoConstraints = false
        useContent.setTitle(TextContent.Buttons.userContent, for: .normal)
        useContent.titleLabel?.font = UIFont.Diwi.button
        useContent.enableButton()
        useContent.addTarget(self, action:#selector(self.buttonTapped(_:)), for: .touchUpInside)
        useContent.roundAllCorners(radius: 30)
        
        view.addSubview(useContent)
        
        NSLayoutConstraint.activate([
            useContent.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            useContent.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            useContent.heightAnchor.constraint(equalToConstant: 60),
            useContent.widthAnchor.constraint(equalToConstant: 170),
        ])
    }
    
    
    @objc func buttonTapped(_ sender: AppButton?) {
        
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewLookVC") as? NewLookVC
        vc!.images = self.images
        self.navigationController?.pushViewController(vc!, animated: true)
//                            self.navigationController?.popViewController(animated: true)
        //
//                            self.dismiss(animated: true, completion: nil)
//        collectionView?.reloadData()
                print("Button is working")
        
        
        
    }
    
    @objc func CancelTap(_ sender: AppButton?) {
        self.dismiss(animated: true, completion: nil)
        print("Cancelled")
    }
    
    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView = collectionView else {
            return
        }
        
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SelectedItemCell.self, forCellWithReuseIdentifier: SelectedItemCell.identifier)
        collectionView.frame = view.bounds
        collectionView.isScrollEnabled = true
        
        view.addSubview(collectionView)
        collectionView.reloadData()
    }
    
    func setupBindings(){
        useContent.rx.tap.bind { [unowned self] in
            self.useContent.buttonPressedAnimation {
            }
     }.disposed(by: disposeBag)
        
        backBtn.rx.tap.bind { [unowned self] in
            self.backBtn.buttonPressedAnimation {
                self.goBack?()
            }
     }.disposed(by: disposeBag)
        
    }
    
    @objc func deleteTap(_ sender: UITapGestureRecognizer) {
        
        
        AlertController.actionSheetWithDestructive(title: "", message: "Delete Photo?", sourceView: self.view, buttons: [], destructiveButtonTitle: "Delete Photo", cancelButtonTitle: "Cancel") { (actionsheet, selectedIndex) in
            self.view.endEditing(true)
            if selectedIndex == 1 {
                let tag = sender.view!.tag
                if tag < self.images.count {
                    self.images.remove(at: tag)
                    self.collectionView?.reloadData()
                }
            }
        }
    }
}
extension SelectedItemViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedItemCell.identifier, for: indexPath) as! SelectedItemCell
        
        cell.selectedItem.image = images[indexPath.row]
        cell.deleteBtn.isUserInteractionEnabled = true
        let delete = UITapGestureRecognizer(target: self, action: #selector(deleteTap(_:)))
        cell.deleteBtn.tag = indexPath.row
        delete.view?.tag = indexPath.row
        cell.deleteBtn.addGestureRecognizer(delete)
        
        
        if self.images.count == 1 {
            cell.deleteBtn.isHidden = true
        }

        
//        if Image.count <= 1 {
//            cell.deleteBtn.isHidden = true
//
//        }
//        self.getThumbnailImageFromVideoUrl(url: URL[indexPath.row] as! URL){ (thumbnailImage) in
//        cell.selectedItem.image = thumbnailImage
//
//       }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    


}

extension SelectedItemViewController {
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
        case .authorized:
            self.presentAssetPicker()
        case .notDetermined:
            requestAuthForLibrary()
        case .denied:
            return
        case .restricted:
            return
        case .limited:
            return
        }
    }
    
    private func requestAuthForLibrary() {
        PHPhotoLibrary.requestAuthorization({status in
            if status == .authorized{
                DispatchQueue.main.async {
                    self.presentAssetPicker()
                }
            }
        })
    }
    
}
extension SelectedItemViewController: AssetsPickerViewControllerDelegate{

    

    
    func presentAssetPicker(){
        
        let picker = AssetsPickerViewController()
        picker.pickerConfig.isOpenCameraFirst = true
        picker.pickerDelegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
        
    }
    
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        
        
    }
    
    func assetsPickerDidCancel(controller: AssetsPickerViewController) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        print(assets)
        print(assets[0])
        for asset in assets {
            
            getAssetThumbnail(asset: asset)
            requestAVAsset(asset: asset)
            }
            
//            PHAsset.getURL(asset)
//            if asset.mediaType == .image {
//                let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
//                options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
//                    return true
//                }
//                self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
//                    completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
//                })
//            } else if asset.mediaType == .video {
//                let options: PHVideoRequestOptions = PHVideoRequestOptions()
//                options.version = .original
//                PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
//                    if let urlAsset = asset as? AVURLAsset {
//                        let localVideoUrl: URL = urlAsset.url as URL
//                        completionHandler(localVideoUrl)
//                    } else {
//                        completionHandler(nil)
//                    }
//                })
//              }
        self.setupView()

        }
    
    func requestAVAsset(asset: PHAsset)-> AVAsset? {
            guard asset.mediaType == .video else { return nil }
            let phVideoOptions = PHVideoRequestOptions()
            phVideoOptions.version = .original
            let group = DispatchGroup()
            let imageManager = PHImageManager.default()
            var avAsset: AVAsset?
            group.enter()
            imageManager.requestAVAsset(forVideo: asset, options: phVideoOptions) { (asset, _, _) in
                avAsset = asset
                group.leave()
                
            }
            group.wait()
            
            return avAsset
        }
    
    static func playVideo (view:UIViewController, asset:PHAsset) {

        guard (asset.mediaType == PHAssetMediaType.video)

                else {
                    print("Not a valid video media type")
                    return
            }

        PHCachingImageManager().requestAVAsset(forVideo: asset as! PHAsset, options: nil, resultHandler: {(asset, audioMix, info) -> Void in

                let asset = asset as! AVURLAsset

                

            let player = AVPlayer(url: asset.url)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
            view.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
               
            })
        }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 600, height: 750), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            if let result = result{
                thumbnail = result
            }
            print(thumbnail)
            self.images.append(thumbnail)
            print(self.images)
        })
        
        return thumbnail
    }
}

// MARK: - UIImagePickerController
extension SelectedItemViewController: UIImagePickerControllerDelegate {
    private func setupCaptureSession(media: UIImagePickerController.SourceType) {
        let vc = UIImagePickerController()
        vc.sourceType = media
        vc.mediaTypes = ["public.image" , "public.movie"]
        vc.allowsEditing = true
        vc.delegate = self
        
//        mediaChoiceWasShown = true
//        MediaChoiceWasShown = true

        
        present(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
        
//            self.mediaChoiceWasShown = false
//            self.showMediaChoiceModal()
        })
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: {

        })
        
        
        let urls = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        
        if imageUrl.isEmpty  && urls == nil{
            
            var selectedImage: UIImage!
            
            if (picker.sourceType == UIImagePickerController.SourceType.camera){
                let imgName = UUID().uuidString
                let documentDirectory = NSTemporaryDirectory()
                let localPath = documentDirectory.appending(imgName)
                selectedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.editedImage.rawValue)] as? UIImage
            print(selectedImage)
                let data = selectedImage.jpegData(compressionQuality: 1)! as NSData
                data.write(toFile: localPath, atomically: true)
//                let photoURL = URL.init(fileURLWithPath: localPath)
//            print(photoURL)
//                imageUrl.append(photoURL)
//                coordinator?.imageUrl = self.imageUrl
//                print(coordinator?.imageUrl ?? "empty")
                
            }else{
                
                imageUrl.append(info[UIImagePickerController.InfoKey.imageURL] as! URL)
                coordinator?.imageUrl = self.imageUrl
                print(imageUrl)
                print(coordinator?.imageUrl ?? "empty")
            }
            
        }
//        coordinator?.Photo.append(imageUrl!)
//        print(coordinator?.Photo)
        if urls != nil{
            getThumbnailImageFromVideoUrl(url: urls!, completion: { (thumbnailImage) in
//                self.coordinator?.Image.append((thumbnailImage ?? UIImage(named: "whatBackground"))!)
                       })
//            let url = urls?.absoluteString
//            coordinator?.Video.append(urls!)
        }
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        image.encodeImageAsBase64Jpeg(compression: 8.0) ?? ""
                let alert = UIAlertController(title: "Add more images/videos", message: "Would you like to add more images or videos?", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                        self.goToCamera?()
        
        
                    }))
                    alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!)  in
                        print("Action")
                        self.setupView()
                    }))
                    self.present(alert, animated: true, completion: nil)
//        coordinator?.Image.append(image)
//        coordinator?.onlyImage.append(image)
//        print(coordinator?.onlyImage)
//        print(coordinator?.Image)
        
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
     DispatchQueue.global().async { //1
       let asset = AVAsset(url: url) //2
       let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
       avAssetImageGenerator.appliesPreferredTrackTransform = true //4
       let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
       do {
         let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
         let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
         DispatchQueue.main.async { //8
           completion(thumbNailImage) //9
         }
       } catch {
         print(error.localizedDescription) //10
         DispatchQueue.main.async {
           completion(nil) //11
         }
       }
     }
   }
}


extension PHAsset {
    
    
    func getURL(ofPhotoWith mPhasset: PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
            
            if mPhasset.mediaType == .image {
                let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
                options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                    return true
                }
                mPhasset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
                    completionHandler(contentEditingInput!.fullSizeImageURL)
                })
            } else if mPhasset.mediaType == .video {
                let options: PHVideoRequestOptions = PHVideoRequestOptions()
                options.version = .original
                PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: { (asset, audioMix, info) in
                    if let urlAsset = asset as? AVURLAsset {
                        let localVideoUrl = urlAsset.url
                        completionHandler(localVideoUrl)
                    } else {
                        completionHandler(nil)
                    }
                })
            }
            
        }

public func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
    if self.mediaType == .image {
        let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
            return true
        }
        self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
            completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
        })
    } else if self.mediaType == .video {
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            if let urlAsset = asset as? AVURLAsset {
                let localVideoUrl: URL = urlAsset.url as URL
                completionHandler(localVideoUrl)
            } else {
                completionHandler(nil)
            }
        })
      }
    }
  }
