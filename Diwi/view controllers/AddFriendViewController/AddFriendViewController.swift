//
//  AddFriendViewController.swift
//  Diwi
//
//  Created by Shane Work on 12/22/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialThemes

class AddFriendViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var outlinedTextField: MDCOutlinedTextField!
    
    let defaults = UserDefaults.standard
    var friends: [String]?
    let key = UserDefaults.GlobalKeys.FriendsListKey
    var scheme: MDCContainerScheming!

    override func viewDidLoad() {
        super.viewDidLoad()
        scheme = MDCContainerScheme()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFriends()
    }
    
    func setupNavBar() {
        configureNavigationBar(largeTitleColor: .white,
                               backgoundColor: UIColor.Diwi.opaqueBlack,
                               tintColor: .white, title: "New Friend",
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func rightBarButtonTapped() {
        if let text = outlinedTextField.text {
            saveFriend(value: text)
        }
    }
    
    func setupUI() {
        outlinedTextField.setOutlineColor(UIColor.Diwi.azure, for: .normal)
        outlinedTextField.setOutlineColor(UIColor.Diwi.azure, for: .editing)
        outlinedTextField.autocapitalizationType = .sentences
        setupNavBar()
    }
    
    func saveFriend(value: String) {
        Loader.show()
        APIManager.addFriend(parameters: ["title":value,"look_ids":["402"]]) { (success, error) in
            Loader.hide()
            if let success = success, success {
                self.outlinedTextField.text = ""
                AlertController.alert(title: "", message: "Friend Added", acceptMessage: "Ok") {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                if error != ""
                {
                    self.outlinedTextField.applyErrorTheme(withScheme: self.scheme)
                    self.outlinedTextField.leadingAssistiveLabel.text = "You already have a friend named \(self.outlinedTextField.text ?? "")"
                    self.outlinedTextField.setOutlineColor(UIColor.red, for: .normal)
                    self.outlinedTextField.setOutlineColor(UIColor.red, for: .editing)
                }else
                {
                    AlertController.alert(message: AlertMsg.errorCreateLook)
                }
            }
        }
    }
    
    func getFriends() {
        let friendsList = defaults.stringArray(forKey: key)
        friends = friendsList
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.outlinedTextField.leadingAssistiveLabel.text != ""
        {
            self.outlinedTextField.applyErrorTheme(withScheme: self.scheme)
            self.outlinedTextField.leadingAssistiveLabel.text = ""
            self.outlinedTextField.setOutlineColor(UIColor.Diwi.azure, for: .normal)
            self.outlinedTextField.setOutlineColor(UIColor.Diwi.azure, for: .editing)
        }
        return true
    }
    
}
