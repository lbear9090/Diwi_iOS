//
//  ImagePreviewViewController.swift
//  Diwi
//
//  Created by softprodigy on 11/02/21.
//  Copyright © 2021 Trim Agency. All rights reserved.
//

import UIKit


class ImagePreviewViewController: UIViewController {

    var images = [UIImage]()
    var callback: ((Bool?)->())?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        imageView.image = images.last
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.callback?(false)
        navigationController?.dismiss(animated: false)
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        self.callback?(true)
        navigationController?.dismiss(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

}
