//
//  PreviewViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 13/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import AVKit

class PreviewViewController: UIViewController {

    var imageView = UIImageView()
    var mainView = UIView()
    var titleLabel = UILabel()
    var imageURL = String()
    var lookID = String()
    var detailButton = UIButton()
    var viewHeight : CGFloat = 500
    var viewWidth : CGFloat!

    
    
    weak var interactiveTransition: BubbleInteractiveTransition?

    
//    var image: UIImage? {
//        didSet {
//            if let image = image {
//                imageView.image = image
//            }
//        }
//    }
    
    var titleStr: String? {
        didSet {
            if let title = titleStr {
                titleLabel.textAlignment = .left
                titleLabel.text = "\(title)"
                titleLabel.textColor = UIColor.Diwi.brownishGrey
                titleLabel.backgroundColor = .white
                titleLabel.font = UIFont.Diwi.titleBold
                titleLabel.numberOfLines = 0
                titleLabel.lineBreakMode = .byWordWrapping //Word Wrap
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateFrames()
        }
    
    func updateFrames()  {
        mainView.frame = CGRect(x: (self.view.bounds.width - viewWidth)/2, y: (self.view.bounds.height - viewHeight)/2, width: viewWidth, height: viewHeight)
        imageView.frame = CGRect(x: 0, y: 0, width: mainView.bounds.width, height: mainView.bounds.height - 40)
        titleLabel.frame = CGRect(x: 10, y: imageView.bounds.height, width: mainView.bounds.width - 10, height: 40)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        viewWidth = self.view.bounds.width - 60
        if let imgUrl = URL.init(string: imageURL) {
            imageView.sd_setShowActivityIndicatorView(true)
            imageView.sd_setIndicatorStyle(.gray)
            imageView.sd_setImage(with: imgUrl, placeholderImage: UIImage.init(named: "placeholderImage.png"), options: .highPriority) { (image, error, type, url) in
                let cgrect = CGRect(x: (self.view.bounds.width - 60)/2, y: (self.view.bounds.height - 500)/2, width: self.view.bounds.width - 60, height: 500)
                self.imageView.image = image
                let rect = AVMakeRect(aspectRatio: image!.size, insideRect: cgrect)
                self.viewWidth = rect.width
                self.viewHeight = rect.height
                self.updateFrames()
                if error == nil {
                }
            }
        }
        
        if #available(iOS 13.0, *) {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterial)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
        } else {
            // Fallback on earlier versions
        }
        
        let button:UIButton = UIButton(frame: UIScreen.main.bounds)
        button.backgroundColor = .clear
        button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        self.view.addSubview(button)
        
        detailButton = UIButton(frame: CGRect(x: 30, y: (self.view.bounds.height - 500)/2, width: self.view.bounds.width - 60, height: 500))
        detailButton.backgroundColor = .clear
        detailButton.addTarget(self, action:#selector(self.detailClicked), for: .touchUpInside)
        
        self.title = "Preview"
        mainView.layer.cornerRadius = 8.0
        mainView.clipsToBounds = true
        mainView.backgroundColor = .white
        //imageView.image = image
        titleLabel.text = titleStr
        mainView.addSubview(imageView)
        mainView.addSubview(titleLabel)
        self.view.addSubview(mainView)
        self.view.addSubview(detailButton)
    }
   
   
    @objc func detailClicked() {
        self.dismiss(animated: true, completion: nil)
        interactiveTransition?.finish()
        NotificationCenter.default.post(name: Notification.Name("Detail"), object: nil, userInfo: ["ID":lookID])
    }
    
    @objc func buttonClicked() {
        self.dismiss(animated: true, completion: nil)
        interactiveTransition?.finish()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
    }

}
