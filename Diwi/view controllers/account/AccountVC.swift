//
//  AccountVC.swift
//  Diwi
//
//  Created by Lucky on 01/17/22.
//  Copyright © 2022 Trim Agency. All rights reserved.
//

import UIKit
import SVProgressHUD
import StoreKit
import RxSwift

class AccountVC: UIViewController {

    // MARK: IBOutlet
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var currentTextField: UITextField!
    @IBOutlet private weak var newPasswordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var logoutButton: UIButton!
    @IBOutlet private weak var basePlanView: UIView!
    @IBOutlet private weak var proPlanView: UIView!
    @IBOutlet private weak var chooseBasePlanButton: UIButton!
    @IBOutlet private weak var chooseProPlanButton: UIButton!
    @IBOutlet private weak var selectedBasePlanImageView: UIImageView!
    @IBOutlet private weak var selectedProPlanImageView: UIImageView!
    @IBOutlet private weak var pricingPlanTitleStackView: UIStackView!
    @IBOutlet private var ticksBasePlanImageView: [UIImageView]!
    @IBOutlet private var tipsBasePlanLabel: [UILabel]!
    @IBOutlet private var ticksProPlanImageView: [UIImageView]!
    @IBOutlet private var tipsProPlanLabel: [UILabel]!
    @IBOutlet private weak var upgradeProfileLabel: UILabel!
    @IBOutlet private weak var diwiBaseLabel: UILabel!
    @IBOutlet private weak var diwiProLabel: UILabel!
    @IBOutlet private weak var perMonthLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var manageSubscriptionLabel: UILabel!

    // MARK: Private
    private let disposeBag = DisposeBag()
    private let emailMessage            = NSLocalizedString("Please enter your email.", comment: "")
    private let passwordMessage         = NSLocalizedString("Enter your password to change your email.", comment: "")
    private let passwordLengthMessage  = NSLocalizedString("Password is too short (minimum is 8 characters)", comment: "")
    private let mismatchPasswordMessage = NSLocalizedString("Password missmatched.", comment: "")

    private var premiumProduct : SKProduct?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupView()
        selectedBasePlan()
        fetchPremiumProduct()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePricingPlanStatus()
    }

    // MARK: Helper methods

    func setupNavBar() {
        if #available(iOS 13.0, *) {
            let buttonAppearance = UIBarButtonItemAppearance()
            buttonAppearance.configureWithDefault(for: .plain)
            buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]

            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = AppColor.hexToUIColor(hex: Colors.pinkColor)
            navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

            navigationBarAppearance.backButtonAppearance = buttonAppearance
            navigationBarAppearance.buttonAppearance = buttonAppearance
            navigationBarAppearance.doneButtonAppearance = buttonAppearance

            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            navigationController?.navigationBar.compactAppearance = navigationBarAppearance
            navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        } else {
            navigationController?.navigationBar.barTintColor = AppColor.hexToUIColor(hex: Colors.pinkColor)
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.tintColor = .white
        }
        navigationController?.navigationBar.tintColor = .white
        self.navigationController?.hideHairline()
    }

    private func fetchPremiumProduct() {
        SVProgressHUD.show()
        Purchases.default.fetchAllFeaturesProduct().subscribe(onNext: { (products) in
            SVProgressHUD.dismiss()
            if let premiumProduct = products?.last {
                self.premiumProduct = premiumProduct
                if let price = premiumProduct.localizedPrice {
                    debugPrint(price)
                    self.priceLabel.text = "\(price)"
                }
            }
        }, onError: { (error) in
            debugPrint(error.localizedDescription)
        }).disposed(by: disposeBag)
    }

    @objc private func selectedBasePlan() {
        chooseBasePlanButton.isHidden = false
        chooseBasePlanButton.backgroundColor = .white
        chooseProPlanButton.isHidden = true
        diwiBaseLabel.textColor = .white
        diwiProLabel.textColor = UIColor(hex: "363636")
        basePlanView.backgroundColor = UIColor(hex: Colors.pinkColor)
        proPlanView.backgroundColor = .white
        selectedBasePlanImageView.image = UIImage(named: "ic-circle-tick")
        tipsBasePlanLabel.forEach({$0.textColor = .white})
        ticksBasePlanImageView.forEach({$0.image = UIImage(named: "whiteTick")})
        selectedProPlanImageView.image = UIImage(named: "unselectedSubscriptionCircle")
        tipsProPlanLabel.forEach({$0.textColor = UIColor(hex: "717171")})
        ticksProPlanImageView.forEach({$0.image = UIImage(named: "pinkTick")})
        perMonthLabel.textColor = UIColor(hex: "717171")
    }

    @objc private func selectedProPlan() {

        if basePlanView != nil {
            chooseBasePlanButton.isHidden = true
            diwiBaseLabel.textColor = UIColor(hex: "363636")
            basePlanView.backgroundColor = .white
            selectedBasePlanImageView.image = UIImage(named: "unselectedSubscriptionCircle")
            tipsBasePlanLabel.forEach({$0.textColor = UIColor(hex: "717171")})
            ticksBasePlanImageView.forEach({$0.image = UIImage(named: "pinkTick")})
        }

        chooseProPlanButton.isHidden = false
        chooseProPlanButton.backgroundColor = .white
        diwiProLabel.textColor = .white
        proPlanView.backgroundColor = UIColor(hex: Colors.pinkColor)
        tipsProPlanLabel.forEach({$0.textColor = .white})
        selectedProPlanImageView.image = UIImage(named: "ic-circle-tick")
        ticksProPlanImageView.forEach({$0.image = UIImage(named: "whiteTick")})
        perMonthLabel.textColor = UIColor.white.withAlphaComponent(0.75)

    }

    @objc private func openManagedSubscription() {
        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }

    @objc private func upgradeProfile() {
        let tierPricingVC = TierPricingViewController(nibName: "TierPricingViewController", bundle: nil)
        tierPricingVC.modalPresentationStyle = .fullScreen
        tierPricingVC.premiumProduct = self.premiumProduct
        self.present(tierPricingVC, animated: true, completion: nil)
    }

    @objc private func onSaveClicked() {
        let result = validateUserData()

        if result.0 {

            let apiFullUrl = webApiBaseURL + ApiURL.user + "/" + KeychainService().getUserId()!
            SVProgressHUD.show()
            APIManager.saveUser(url:apiFullUrl,parameters: result.1!) { [unowned self] (success, error)  in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if success == true {
                        KeychainService().setUserPassword(password: self.confirmPasswordTextField.text ?? "")
                        KeychainService().setUserEmail(email: self.emailTextField.text ?? "")
                        self.currentTextField.text = ""
                        self.newPasswordTextField.text = ""
                        self.confirmPasswordTextField.text = ""
                    } else {
                        self.showMessage("Something went wrong. Please try again later.")
                    }
                }

            }
        }
    }

    private func validateUserData() -> (Bool, [String : Any]?)  {
        if emailTextField.text == "" {
            showMessage(emailMessage)
            return (false,nil)
        }else if currentTextField.text == "" {
            showMessage(passwordMessage)
            return (false,nil)
        }else if emailTextField.text == KeychainService().getUserEmail() && currentTextField.text != ""  && newPasswordTextField.text == ""  && confirmPasswordTextField.text == ""{
            let userObj = ["email": emailTextField.text ?? "","current_password": currentTextField.text ?? ""] as [String : Any]
            return (true,userObj)
        } else if emailTextField.text != KeychainService().getUserEmail() && currentTextField.text != ""  && newPasswordTextField.text == ""  && confirmPasswordTextField.text == ""{
            let userObj = ["email": emailTextField.text ?? "","current_password": currentTextField.text ?? ""] as [String : Any]
            return (true,userObj)
        } else if newPasswordTextField.text?.count ?? 0 < 8 {
            showMessage(passwordLengthMessage)
            return (false, nil)
        } else if confirmPasswordTextField.text?.count ?? 0 == 0 {
            showMessage(passwordMessage)
            return (false, nil)
        } else if newPasswordTextField.text != confirmPasswordTextField.text {
            showMessage(mismatchPasswordMessage)
            return (false, nil)
        } else if newPasswordTextField.text == confirmPasswordTextField.text{
            let userObj = ["current_password":currentTextField.text ?? "","new_password": newPasswordTextField.text ?? "","password_confirmation": confirmPasswordTextField.text ?? ""] as [String : Any]
            return (true, userObj)
        } else {
            let userObj = ["email": emailTextField.text ?? "","current_password":currentTextField.text ?? "","new_password": newPasswordTextField.text ?? "","password_confirmation": confirmPasswordTextField.text ?? ""] as [String : Any]
            return (true, userObj)
        }
    }

    private func logoutConfirmation() {
        AlertController.actionSheetWithDestructive(title: "", message: "Do you want to logout?", sourceView: self.view, buttons: [], destructiveButtonTitle: "Logout", cancelButtonTitle: "Cancel") { (actionsheet, selectedIndex) in
            if selectedIndex == 1 {
                KeychainService().clearValues()
                KeychainService().clearAll()
                let loginViewController = LoginViewController()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = UINavigationController(rootViewController: loginViewController)
                appDelegate.window?.makeKeyAndVisible()
            }
        }
    }

    private func updatePricingPlanStatus() {
        if Purchases.default.hasFreePlan {
            basePlanView?.removeFromSuperview()
        }
        if Purchases.default.hasProPlan {
            basePlanView?.removeFromSuperview()
            proPlanView?.removeFromSuperview()
            pricingPlanTitleStackView?.removeFromSuperview()
        }
    }

    private func setupView() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Diwi.h1b]
        self.navigationItem.title = "Account"

        let saveButton = UIButton(type: .custom)
        saveButton.titleLabel?.font = UIFont.Diwi.h1
        saveButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.addTarget(self, action: #selector(onSaveClicked), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        chooseBasePlanButton.roundAllCorners(radius: chooseBasePlanButton.frame.height/2)
        chooseProPlanButton.roundAllCorners(radius: chooseProPlanButton.frame.height/2)
        chooseBasePlanButton.isHidden = true
        chooseProPlanButton.isHidden = true
        emailTextField.setLeftPaddingPoints(10)
        emailTextField.roundAllCorners(radius: 4, borderColor: UIColor(hex: Colors.textFieldBorderColor))
        currentTextField.setLeftPaddingPoints(10)
        currentTextField.isSecureTextEntry = true
        currentTextField.roundAllCorners(radius: 4, borderColor: UIColor(hex: Colors.textFieldBorderColor))
        newPasswordTextField.setLeftPaddingPoints(10)
        newPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.roundAllCorners(radius: 4, borderColor: UIColor(hex: Colors.textFieldBorderColor))
        confirmPasswordTextField.setLeftPaddingPoints(10)
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.roundAllCorners(radius: 4, borderColor: UIColor(hex: Colors.textFieldBorderColor))
        basePlanView.roundAllCorners(radius: 4, borderColor: UIColor(hex: Colors.pinkColor))
        proPlanView.roundAllCorners(radius: 4, borderColor: UIColor(hex: Colors.pinkColor))
        logoutButton.setTitle("", for: .normal)

        let tapGestureBasePlan = UITapGestureRecognizer(target: self, action: #selector(selectedBasePlan))
        basePlanView.isUserInteractionEnabled = true
        basePlanView.addGestureRecognizer(tapGestureBasePlan)

        let tapGestureProPlan = UITapGestureRecognizer(target: self, action: #selector(selectedProPlan))
        proPlanView.isUserInteractionEnabled = true
        proPlanView.addGestureRecognizer(tapGestureProPlan)

        let tapGestureUpgradeProfile = UITapGestureRecognizer(target: self, action: #selector(upgradeProfile))
        upgradeProfileLabel.isUserInteractionEnabled = true
        upgradeProfileLabel.addGestureRecognizer(tapGestureUpgradeProfile)

        let tapGestureManageSubscription = UITapGestureRecognizer(target: self, action: #selector(openManagedSubscription))
        manageSubscriptionLabel.isUserInteractionEnabled = true
        manageSubscriptionLabel.addGestureRecognizer(tapGestureManageSubscription)

        logoutButton.rx.tap.bind { [unowned self] in
            self.logoutConfirmation()
        }.disposed(by:self.disposeBag)

        chooseBasePlanButton.rx.tap.bind { [unowned self] in
            debugPrint("Choose Base Plan")
            self.basePlanView.removeFromSuperview()
            Purchases.default.hasFreePlan = true
        }.disposed(by:self.disposeBag)

        chooseProPlanButton.rx.tap.bind { [unowned self] in
            if let productIdentifier = self.premiumProduct?.productIdentifier {
                Purchases.default.purchaseProduct(productIdentifier).subscribe(onNext: { (isSuccess) in
                    self.showMessage("You have full access!\nEnjoy your Diwi")
                    self.proPlanView.removeFromSuperview()
                    self.basePlanView.removeFromSuperview()
                    self.pricingPlanTitleStackView.removeFromSuperview()
                }, onError: { (error) in
                    self.showMessage("We could not verify eligibility for this upgrade.")
                }).disposed(by: disposeBag)
            }
        }.disposed(by:self.disposeBag)
        /// Fill data
        emailTextField.text = KeychainService.shared.getUserEmail()
    }

    private func showMessage(_ msg: String) {
        let alert = UIAlertController(title: "Diwi", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

}
