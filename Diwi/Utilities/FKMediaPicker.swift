////
////  FKMediaPicker.swift
////  SEF
////
////  Created by Apple on 13/10/2017.
////  Copyright © 2017 Apple. All rights reserved.
////
//
//import UIKit
//
//class FKMediaPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    static let mediaPicker = FKMediaPicker()
//
//    typealias DidFinishPickingMediaBlock = (_ info: [UIImagePickerController.InfoKey: Any], _ pickedImage: UIImage?) -> Void
//    private var finishedPickingMediaWithInfo: DidFinishPickingMediaBlock?
//
//    typealias DidCancelledPickingMediaBlock = () -> Void
//    var cancelledPickingMediaBlock: DidCancelledPickingMediaBlock?
//
//    func pickMediaFromCamera(cameraBlock: @escaping DidFinishPickingMediaBlock) {
//
//        finishedPickingMediaWithInfo = cameraBlock
//
//        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
//
//            if let currentController = UIWindow.currentController {
//                let imagePicker = UIImagePickerController()
//                imagePicker.sourceType = UIImagePickerController.SourceType.camera
//                imagePicker.delegate = self
////                imagePicker.allowsEditing = true
//                currentController.present(imagePicker, animated: true, completion: nil)
//            }
//        } else {
//            pickMediaFromGallery(galleryBlock: { (info: [UIImagePickerController.InfoKey: Any], pickedImage: UIImage?) in
//                cameraBlock(info, pickedImage)
//            })
//        }
//    }
//
//    func pickMediaFromGallery(galleryBlock: @escaping DidFinishPickingMediaBlock) {
//
//        if let currentController = UIWindow.currentController {
//            finishedPickingMediaWithInfo = galleryBlock
//            let imagePicker: UIImagePickerController = UIImagePickerController()
//            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//            imagePicker.delegate = self
////            imagePicker.allowsEditing = true
//            currentController.present(imagePicker, animated: true, completion: nil)
//        }
//    }
//
//    // MARK: - - image picker delegate
//    func imagePickerController(_ picker: UIImagePickerController,
//                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        picker.dismiss(animated: true, completion: nil)
//        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            if let finishedPickingMediaWithInfo = finishedPickingMediaWithInfo {
//                finishedPickingMediaWithInfo(info, pickedImage)
//            }
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//        if let cancelledPickingMediaBlock = cancelledPickingMediaBlock {
//            cancelledPickingMediaBlock()
//        }
//    }
//}
