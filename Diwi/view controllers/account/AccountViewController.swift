//
//  AccountViewController.swift
//  Diwi
//
//  Created by Shane Work on 11/12/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialThemes
import MaterialComponents.MaterialButtons
import MessageUI
import WebKit

class AccountViewController: UIViewController,MFMailComposeViewControllerDelegate,UITextFieldDelegate, WKUIDelegate {

    
    
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var emailTextField: DTTextField!
    @IBOutlet weak var currentPasswordTextField: DTTextField!
    @IBOutlet weak var newPasswordTextField: DTTextField!
    @IBOutlet weak var confirmPasswordTextField: DTTextField!
    @IBOutlet weak var successBannerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var btnContactUs: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblCurrentPassword: UILabel!
    @IBOutlet weak var lblNewPassword: UILabel!
    @IBOutlet weak var lblConfirmNewPassword: UILabel!
    
    var scheme: MDCContainerScheming!
    var materialTextfields: [DTTextField]?
    let tableView = UITableView()
    let lblpricingPlan = UILabel()
    let upgradeProfile = UILabel()
    var lblCancel = UILabel()
    var diwiImage = UIImageView()
    var lblInfo = UILabel()
    var viewForCollection = UIView()
    var imageCollectionView: UICollectionView?
    var selectedIndex = -1
    let emailMessage            = NSLocalizedString("Please enter your email.", comment: "")
    let passwordMessage         = NSLocalizedString("Enter your password to change your email.", comment: "")
    let passwordLengthMessage  = NSLocalizedString("Password is too short (minimum is 8 characters)", comment: "")
    let mismatchPasswordMessage = NSLocalizedString("Password missmatched.", comment: "")
    var selectedSortingRow = -1
   
    
    var image: [UIImage] = [
        UIImage(named: "photo")!,
        UIImage(named: "photo1")!,
        UIImage(named: "photo2")!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPricingPlan()
        setupUpgradeProfile()
        setupTableView()
        emailTextField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
        currentPasswordTextField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
        newPasswordTextField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)

        setupNavBar(isEditingLook: false)
        scheme = MDCContainerScheme()
        styleTextFields()
        materialTextfields = [emailTextField, currentPasswordTextField, newPasswordTextField, confirmPasswordTextField]
        setUserData()
        
  
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
  
    
    func setUserData() {
        let keychainService = KeychainService()
        emailTextField.text = keychainService.getUserEmail()
        //        currentPasswordTextField.text = keychainService.getUserPassword()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        AlertController.actionSheetWithDestructive(title: "", message: "Do you want to logout?", sourceView: self.view, buttons: [], destructiveButtonTitle: "Logout", cancelButtonTitle: "Cancel") { (actionsheet, selectedIndex) in
            self.view.endEditing(true)
            if selectedIndex == 1 {
                KeychainService().clearValues()
                KeychainService().clearAll()
                self.tabBarController?.tabBar.isHidden = true
                let vc = LoginViewController()
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        //navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func contactUsButton(_ sender: Any) {
        let recipientEmail = "info@didiwearit.com"
        
        // Show default mail composer
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            present(mail, animated: true)
            
        } else if let emailUrl = createEmailUrl(to: recipientEmail) {
            UIApplication.shared.open(emailUrl)
        }
    }
    
    private func setupPricingPlan(){
        lblpricingPlan.translatesAutoresizingMaskIntoConstraints = false
        lblpricingPlan.textColor = UIColor.black
        lblpricingPlan.text = "Pricing Plans:"
        lblpricingPlan.font = UIFont.Diwi.titleBold
        scrollContentView.addSubview(lblpricingPlan)
        
        NSLayoutConstraint.activate([
            lblpricingPlan.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor, constant: 22),
            lblpricingPlan.topAnchor.constraint(equalTo: btnLogout.bottomAnchor, constant: 28),
            ])
        
    }
    
    private func setupUpgradeProfile(){
        upgradeProfile.translatesAutoresizingMaskIntoConstraints = false
        upgradeProfile.textColor = UIColor.Diwi.barney
        upgradeProfile.text = "Upgrade Your Profile"
        upgradeProfile.attributedText = NSAttributedString(string: "Upgrade Your Profile", attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
        upgradeProfile.font = UIFont.Diwi.floatingButton
        upgradeProfile.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(upgradeProfileTapped))
        upgradeProfile.addGestureRecognizer(gestureRecognizer)
    
        
        scrollContentView.addSubview(upgradeProfile)
        
        NSLayoutConstraint.activate([
            upgradeProfile.leftAnchor.constraint(equalTo: lblpricingPlan.rightAnchor, constant: 10),
            upgradeProfile.topAnchor.constraint(equalTo: btnLogout.bottomAnchor, constant: 31),
            ])
    }
    
    private func setupTableView(){
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SubscriptionTableViewCell.self, forCellReuseIdentifier: SubscriptionTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.reloadData()
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        scrollContentView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: lblpricingPlan.bottomAnchor, constant: 10),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
    }
    
    func showWebView() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webView.leftAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            webView.bottomAnchor
                .constraint(equalTo: self.view.superview!.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
        
    }
    private func setupCrossButton(){
        
        lblCancel.translatesAutoresizingMaskIntoConstraints = false
        lblCancel.textColor = .gray
        lblCancel.text = "X"
        lblCancel.font = UIFont.Diwi.h2
        lblCancel.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(crossTapped))
        lblCancel.addGestureRecognizer(gestureRecognizer)
        
        scrollContentView.addSubview(lblCancel)
        
        NSLayoutConstraint.activate([
            lblCancel.topAnchor.constraint(equalTo: scrollContentView.topAnchor),
            lblCancel.rightAnchor.constraint(equalTo: scrollContentView.rightAnchor, constant: -15),
            lblCancel.heightAnchor.constraint(equalToConstant: 30),
            lblCancel.widthAnchor.constraint(equalToConstant: 30),
            
            ])
    }
    
    
    private func setupDiwiLogo(){
        
        diwiImage.translatesAutoresizingMaskIntoConstraints = false
        diwiImage.contentMode = .scaleAspectFill
        diwiImage.image = UIImage(named: "diwiLogo")
        
        scrollContentView.addSubview(diwiImage)
        
        NSLayoutConstraint.activate([
            diwiImage.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 10),
            diwiImage.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            diwiImage.heightAnchor.constraint(equalToConstant: 100),
            diwiImage.widthAnchor.constraint(equalToConstant: 70),
            ])
        
    }
    
    private func setupInfo(){
        
        lblInfo.translatesAutoresizingMaskIntoConstraints = false
        lblInfo.textColor = UIColor.black
        lblInfo.text = "All your looks captured in one place"
        lblInfo.font = UIFont.Diwi.titleBold
        scrollContentView.addSubview(lblInfo)
        
        NSLayoutConstraint.activate([
            lblInfo.topAnchor.constraint(equalTo: diwiImage.bottomAnchor, constant: 5),
            lblInfo.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            lblInfo.heightAnchor.constraint(equalToConstant: 30),
            ])
        
    }
    
    private func setupCollectionView(){
        viewForCollection.translatesAutoresizingMaskIntoConstraints = false
        imageCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView = imageCollectionView else {
            return
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProfileCollectionView.self, forCellWithReuseIdentifier: ProfileCollectionView.identifier)
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .white
        scrollContentView.addSubview(viewForCollection)
        viewForCollection.addSubview(collectionView)
       
        NSLayoutConstraint.activate([
            viewForCollection.topAnchor.constraint(equalTo: lblInfo.bottomAnchor, constant: 5),
            viewForCollection.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewForCollection.rightAnchor.constraint(equalTo: view.rightAnchor),
            viewForCollection.heightAnchor.constraint(equalToConstant: 320),
            ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: lblInfo.bottomAnchor, constant: 5),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 320),
            ])
        
    }
    
    @objc func upgradeProfileTapped(){
        
        self.messageLable.isHidden = true
        self.emailTextField.isHidden = true
        self.currentPasswordTextField.isHidden = true
        self.newPasswordTextField.isHidden = true
        self.confirmPasswordTextField.isHidden = true
        self.btnTerms.isHidden = true
        self.btnContactUs.isHidden = true
        self.btnLogout.isHidden = true
        self.lblEmail.isHidden = true
        self.lblCurrentPassword.isHidden = true
        self.lblNewPassword.isHidden = true
        self.lblConfirmNewPassword.isHidden = true
        self.lblpricingPlan.isHidden = true
        self.upgradeProfile.isHidden = true
        self.lblCancel.isHidden = false
        self.diwiImage.isHidden = false
        self.lblInfo.isHidden = false
        self.viewForCollection.isHidden = false
        setupDiwiLogo()
//        setupDiwiLogo()
        setupInfo()
//        setupInfo()
        setupCollectionView()
        setupCollectionView()
        setupCrossButton()
       
    }
    
    @objc func crossTapped(){
        self.messageLable.isHidden = false
        self.emailTextField.isHidden = false
        self.currentPasswordTextField.isHidden = false
        self.newPasswordTextField.isHidden = false
        self.confirmPasswordTextField.isHidden = false
        self.btnTerms.isHidden = false
        self.btnContactUs.isHidden = false
        self.btnLogout.isHidden = false
        self.lblEmail.isHidden = false
        self.lblCurrentPassword.isHidden = false
        self.lblNewPassword.isHidden = false
        self.lblConfirmNewPassword.isHidden = false
        self.lblpricingPlan.isHidden = false
        self.upgradeProfile.isHidden = false
        self.lblCancel.isHidden = true
        self.diwiImage.isHidden = true
        self.lblInfo.isHidden = true
        self.viewForCollection.isHidden = true
    }
    
    
    @IBAction func tncBtn(_ sender: Any) {
        showWebView()
        isWebViewShowing = true
        self.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.tabBar.isHidden = true
        if let docUrl = Bundle.main.url(forResource: "DiWiTnCDoc", withExtension: "docx") {
            let myRequest = URLRequest(url: docUrl)
            webView.load(myRequest)
        }
    }
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private func createEmailUrl(to: String) -> URL? {
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)")
        let defaultUrl = URL(string: "mailto:\(to)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        
        return defaultUrl
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func styleTextFields() {
        
        emailTextField.floatingDisplayStatus = .never
        currentPasswordTextField.floatingDisplayStatus = .never
        newPasswordTextField.floatingDisplayStatus = .never
        confirmPasswordTextField.floatingDisplayStatus = .never
        
        emailTextField.TFborderColor = UIColor.Diwi.azure
        currentPasswordTextField.TFborderColor = UIColor.Diwi.azure
        newPasswordTextField.TFborderColor = UIColor.Diwi.azure
        confirmPasswordTextField.TFborderColor = UIColor.Diwi.azure
    }
    
    func toggleHelperText(forTextField textField: MDCOutlinedTextField, withText text: String) {
        textField.leadingAssistiveLabel.text = text
        textField.setLeadingAssistiveLabelColor(UIColor.red, for: .normal)
    }
    
  
    @objc func didTapSave() {
        
        let result = checkTextFields()
        if result.0 {
            Loader.show()
            print(result.1!.toJsonString())
            let apiFullUrl = webApiBaseURL+ApiURL.user+"/"+KeychainService().getUserId()!
            
            APIManager.saveUser(url:apiFullUrl,parameters: result.1!) { (success, error) in
                if let success = success, success {
                    KeychainService().setUserPassword(password: self.confirmPasswordTextField.text ?? "")
                    KeychainService().setUserEmail(email: self.emailTextField.text ?? "")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.successBannerHeightConstraint.constant = 50
                            self.currentPasswordTextField.text = ""
                            self.newPasswordTextField.text = ""
                            self.confirmPasswordTextField.text = ""
                            self.view.layoutIfNeeded()
                        }, completion: {res in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.successBannerHeightConstraint.constant = 0
                                    self.view.layoutIfNeeded()
                                }, completion: {res in
                                })
                            })
                        })
                    })
                } else {
                    if ((error?.isEmpty) != nil)
                    {
                        AlertController.alert(message: error ?? AlertMsg.errorCreateLook)
                    }else
                    {
                        AlertController.alert(message: AlertMsg.errorCreateLook)
                    }
                }
                Loader.hide()
            }
        }
    }
    
    func checkTextFields() -> (Bool,[String : Any]?) {
        
        if emailTextField.text == "" {
            emailTextField.showError(message: emailMessage)
            return (false,nil)
        }else if currentPasswordTextField.text == "" {
            currentPasswordTextField.showError(message: passwordMessage)
            return (false,nil)
        }else if emailTextField.text == KeychainService().getUserEmail() && currentPasswordTextField.text != ""  && newPasswordTextField.text == ""  && confirmPasswordTextField.text == ""{
            let userObj = ["email": emailTextField.text ?? "","current_password": currentPasswordTextField.text ?? ""] as [String : Any]
            return (true,userObj)
        } else if emailTextField.text != KeychainService().getUserEmail() && currentPasswordTextField.text != ""  && newPasswordTextField.text == ""  && confirmPasswordTextField.text == ""{
            let userObj = ["email": emailTextField.text ?? "","current_password": currentPasswordTextField.text ?? ""] as [String : Any]
            return (true,userObj)
        } else if newPasswordTextField.text?.count ?? 0 < 8 {
            newPasswordTextField.showError(message: passwordLengthMessage)
            return (false,nil)
        } else if confirmPasswordTextField.text?.count ?? 0 == 0 {
            confirmPasswordTextField.showError(message: passwordMessage)
            return (false,nil)
        } else if newPasswordTextField.text != confirmPasswordTextField.text {
            confirmPasswordTextField.showError(message: mismatchPasswordMessage)
            return (false,nil)
        } else if newPasswordTextField.text == confirmPasswordTextField.text{
            let userObj = ["current_password":currentPasswordTextField.text ?? "","new_password": newPasswordTextField.text ?? "","password_confirmation": confirmPasswordTextField.text ?? ""] as [String : Any]
            return (true,userObj)
        } else {
            let userObj = ["email": emailTextField.text ?? "","current_password":currentPasswordTextField.text ?? "","new_password": newPasswordTextField.text ?? "","password_confirmation": confirmPasswordTextField.text ?? ""] as [String : Any]
            return (true,userObj)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar(largeTitleColor: .white, backgoundColor: UIColor.Diwi.azure, tintColor: .white, title: "Account", preferredLargeTitle: false, searchController: nil)
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
    }
    
    private func setupNavBar(isEditingLook : Bool) {
        configureNavigationBar(largeTitleColor: .white, backgoundColor: UIColor.Diwi.azure, tintColor: .white, title: "Account", preferredLargeTitle: false, searchController: nil)
        
//        if isEditingLook
//        {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil

            let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(title:"Cancel",style: .plain,target: self,action:#selector(leftBarButtonTapped))
            
            let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title:"Save",style: .plain,target: self,action:#selector(didTapSave))
            
            self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
            self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
//        }else
//        {
//            let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title:"Save",style: .plain,target: self,action:#selector(didTapSave))
//            self.navigationItem.rightBarButtonItem = rightBarButtonItem
//            self.navigationItem.leftBarButtonItem = nil
//
//        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Diwi.navigationButton]
    }
    
    var isWebViewShowing = false
    
    @objc func leftBarButtonTapped() {
        
        if isWebViewShowing {
            configureNavigationBar(largeTitleColor: .white, backgoundColor: UIColor.Diwi.azure, tintColor: .white, title: "Account", preferredLargeTitle: false, searchController: nil)

            self.tabBarController?.tabBar.isHidden = false
            let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title:"Save",style: .plain,target: self,action:#selector(didTapSave))
            self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
            isWebViewShowing = false
            webView.removeFromSuperview()
        } else {
            self.view.endEditing(true)
            currentPasswordTextField.text = ""
            newPasswordTextField.text = ""
            confirmPasswordTextField.text = ""
            setUserData()
            self.tabBarController?.selectedIndex = 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TabbarUpdate"), object: nil, userInfo: nil)
            //setupNavBar(isEditingLook: false)
        }
    }
    
    @objc fileprivate func textFieldTextChanged(){
        //setupNavBar(isEditingLook: true)
    }
}

extension AccountViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 2
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionTableViewCell.identifier, for: indexPath) as! SubscriptionTableViewCell
        tableView.beginUpdates()
        tableView.endUpdates()
        cell.setupView()
        cell.img.image = UIImage(named: "unselectedSubscriptionCircle")
        cell.imgScnd.image = UIImage(named: "pinkTick")
        cell.imgThrd.image = UIImage(named: "pinkTick")
        cell.imgFrth.image = UIImage(named: "pinkTick")
        cell.layer.borderColor = UIColor.Diwi.barney.cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 10
        print(indexPath.section)
        
        if indexPath.section == 1{
            cell.lblFirst.text = "DIWI Pro Plan"
            cell.lblAmount.text = "$7.99/month"
            cell.lblSecond.text = "Unlimited Daily Looks"
            cell.lblThird.text = "Unlimited Video Uploads"
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SubscriptionTableViewCell
//        tableView.beginUpdates()
//        tableView.endUpdates()
        self.tableView.beginUpdates()
            selectedSortingRow = indexPath.section
            self.tableView.endUpdates()
        cell?.view.backgroundColor = UIColor.Diwi.barney
        cell?.lblAmount.textColor = .white
        cell?.lblFirst.textColor = .white
        cell?.lblSecond.textColor = .white
        cell?.lblThird.textColor = .white
        cell?.lblFourth.textColor = .white
        cell?.btnChoose.isHidden = false
        cell?.img.backgroundColor = .white
        cell?.img.layer.borderWidth = 1.0
        cell?.img.layer.masksToBounds = false
        cell?.img.layer.borderColor = UIColor.white.cgColor
        cell?.img.layer.cornerRadius = cell!.img.frame.size.width / 2
        cell?.img.clipsToBounds = true
        cell?.img.image = UIImage(named: "selectedSubscriptionCircle")
        cell?.imgScnd.image = UIImage(named: "whiteTick")
        cell?.imgThrd.image = UIImage(named: "whiteTick")
        cell?.imgFrth.image = UIImage(named: "whiteTick")
        print(indexPath.row)
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SubscriptionTableViewCell
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.beginUpdates()
        selectedSortingRow = -1
        tableView.endUpdates()
//        if indexPath.section == selectedIndex{
//                selectedIndex = -1
//            }else{
//                selectedIndex = indexPath.section
//
//            }
            tableView.reloadData()
        cell?.view.backgroundColor = .white
        cell?.lblAmount.textColor = .black
        cell?.lblFirst.textColor = .black
        cell?.lblSecond.textColor = .black
        cell?.lblThird.textColor = .black
        cell?.lblFourth.textColor = .black
        cell?.img.backgroundColor = .white
        cell?.btnChoose.isHidden = true
        cell?.img.layer.borderWidth = 1.0
        cell?.img.layer.masksToBounds = false
        cell?.img.layer.cornerRadius = cell!.img.frame.size.width / 2
        cell?.img.clipsToBounds = true
        cell?.img.image = UIImage(named: "unselectedSubscriptionCircle")
        cell?.imgScnd.image = UIImage(named: "pinkTick")
        cell?.imgThrd.image = UIImage(named: "pinkTick")
        cell?.imgFrth.image = UIImage(named: "pinkTick")
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if selectedIndex == indexPath.section{
        
//        if let selectedRows = tableView.indexPathsForSelectedRows, selectedRows.contains(indexPath.section) {
        
//        if self.selectedSortingRow == indexPath.section {
            
            if self.tableView.indexPathForSelectedRow?.section == indexPath.section {
                
                return 280

            } else {

                return 230
            }
//        return 240
//        if indexPath.row == selectedIndex
//            {
//                return 330
//            }else{
//                return 240
//            }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

    let headerView = UIView()
    headerView.backgroundColor = UIColor.white
        return headerView

        }
    

    
}


extension AccountViewController: UICollectionViewDataSource, UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return image.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionView.identifier, for: indexPath) as! ProfileCollectionView
//        if indexPath.row == 0{
//            cell.selectedItem.image = UIImage(named: "photo")
//
//        } else if indexPath.row == 1{
//
//            cell.selectedItem.image = UIImage(named: "photo1")
//        }else{
//            cell.selectedItem.image = UIImage(named: "photo2")
//
//        }
        cell.selectedItem.image = image[indexPath.row]
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
//        print(visibleIndexPaths)
//        if visibleIndexPaths[0] = {
        
        let cell = collectionView.cellForItem(at: indexPath)
        for var i in (0...2)
        {
            
            return CGSize(width: (UIScreen.main.bounds.width/2)+40  , height: 330)
        }
           return CGSize(width: (UIScreen.main.bounds.width/2)+40  , height: 330)
//        }else{
//            return CGSize(width: (UIScreen.main.bounds.width/2)-40  , height: 330)

//        }
        
        
    }
    
}
