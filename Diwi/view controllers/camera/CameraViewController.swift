//
//  CameraViewController.swift
//  Diwi
//
//  Created by Shane Work on 11/25/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import Foundation
import ImagePicker

class CameraViewController: UIViewController {
    
//    public var imageAssets: [UIImage] {
//      return AssetManager.resolveAssets(imagePicker.stack.assets)
//    }

    @IBOutlet weak var tabBarIndicatorWidth: NSLayoutConstraint!
    @IBOutlet weak var tabBarIndicator: UIView!
    
    var lookImages: [UIImage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarIndicator.isHidden = true
       // amimateTabBarIndicator()
        setupUI()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.presentImagePickerController()
        })
    }
    
    func setupUI() {
        configureNavigationBar(largeTitleColor: .white,
                               backgoundColor: UIColor.Diwi.azure,
                               tintColor: .white, title: "",
                               preferredLargeTitle: false,
                               searchController: nil)
        
        self.view.backgroundColor = UIColor.white
    }
    
    func amimateTabBarIndicator() {
        tabBarIndicator.backgroundColor = UIColor.Diwi.barney
        tabBarIndicatorWidth.constant = self.view.frame.width / 3
    }
    
    func presentImagePickerController() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
  
}

extension CameraViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {

    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        lookImages = images
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }



}
 
