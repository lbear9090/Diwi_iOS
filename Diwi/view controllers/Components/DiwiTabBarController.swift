//
//  DiwiTabBarController.swift
//  Diwi
//
//  Created by Dominique Miller on 3/23/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

class DiwiTabBarController: UITabBarController {
    
    let looksViewController = UINavigationController(rootViewController: LooksViewController())
    //let cameraViewController = UINavigationController(rootViewController: CameraViewController())
    //    let cameraViewController = UINavigationController(rootViewController: NewLookVC())
    let accountViewController = UINavigationController(rootViewController:UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccountVC"))
    //let accountViewController = UINavigationController(rootViewController: AccountViewController())
    let cameraViewController = UINavigationController(rootViewController: SelectedItemViewController())
//    self.navigationController?.pushViewController(cameraViewController, animated: true)

    
//    let cameraViewController = UINavigationController(rootViewController:UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewLookVC") as! NewLookVC)
    
    var image: UIImageView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        setupTabBarItems()
        setupControllersArray()
        self.tabBar.barTintColor = UIColor.white
        image = UIImageView(image: createImage(color: UIColor.Diwi.barney, size: tabBar.frame.size, lineHeight: 4))
        tabBar.addSubview(image!)
        image?.frame.origin.x = (CGFloat(self.selectedIndex) * tabBar.frame.size.width/3)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "TabbarUpdate"), object: nil)
        
    }
    
    func addLabelAtTabBarItemIndex(tabIndex: Int, value: String) {
         let tabBarItemCount = CGFloat(self.tabBar.items!.count)
         let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
        label.backgroundColor = .red
         label.text = value
         self.tabBar.addSubview(label)
    }
    
    @objc func showSpinningWheel(_ notification: NSNotification) {
        image?.frame.origin.x = (CGFloat(self.selectedIndex) * tabBar.frame.size.width/3)
    }
    
    func createImage(color: UIColor, size: CGSize, lineHeight: CGFloat) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width/3, height: lineHeight )
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func createCircleImage(color: UIColor, size: CGSize, lineHeight: CGFloat) -> UIImage {
            let rect: CGRect = CGRect(x: 0, y: size.height - lineHeight, width: size.width, height: lineHeight )
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setFill()
            UIRectFill(rect)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }
    
    private func setupControllersArray() {
        self.viewControllers = [
            cameraViewController,
            looksViewController,
            accountViewController
        ]
        self.selectedIndex = 1
    }
    
    private func setupTabBarItems() {
        looksViewController.tabBarItem.image = UIImage.Diwi.closetIcon
        looksViewController.tabBarItem.selectedImage = UIImage.Diwi.closetSelected.withRenderingMode(.alwaysOriginal)
        
        accountViewController.tabBarItem.image = addTextToImage(text: getUserData(), inImage: UIImage.Diwi.accountBlueIconSelected, atPoint: CGPoint(x: 20, y: 20)).withRenderingMode(.alwaysOriginal)
        accountViewController.tabBarItem.selectedImage = addTextToImage(text: getUserData(), inImage: UIImage.Diwi.accountBlueIconSelected, atPoint: CGPoint(x: 20, y: 20)).withRenderingMode(.alwaysOriginal)
        //accountViewController.tabBarItem.title = "HG"
        
        //accountViewController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: 2.0);
        accountViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 05.0, right: 0.0);
        
        cameraViewController.tabBarItem.image = UIImage.Diwi.cameraUnselected
        cameraViewController.tabBarItem.selectedImage = UIImage.Diwi.cameraUnselected.withRenderingMode(.alwaysOriginal)
        
        looksViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
        accountViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
//        accountViewController.tabBarItem.title = ""
        cameraViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
        
    }
    
    func getUserData() -> String {
        let keychainService = KeychainService()
        let name = keychainService.getUserEmail()
        if (name?.count ?? 0) > 0{
            return ((name!.first)?.uppercased())!
        }
        return "D"
    }
    
    func addTextToImage(text: String, inImage: UIImage, atPoint:CGPoint) -> UIImage{
        
        let textColor = UIColor.white
        let textFont = UIFont.Diwi.smallText
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ]
        
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, 0.0)
        UIColor.Diwi.azure.setFill()
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        let drawingBounds = CGRect(x: 0.0, y: 0.0, width: inImage.size.width, height: inImage.size.height)
        let textSize = text.size(withAttributes: [NSAttributedString.Key.font:textFont])
        let textRect = CGRect(x: drawingBounds.size.width/2 - textSize.width/2, y: drawingBounds.size.height/2 - textSize.height/2,
                              width: textSize.width, height: textSize.height)
        text.draw(in: textRect, withAttributes: textFontAttributes)
        let newImag = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImag
    }
    
}

extension DiwiTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.selectedIndex != 0
        {
            image?.frame.origin.x = (CGFloat(self.selectedIndex) * tabBar.frame.size.width/3)
        }
    }
}
