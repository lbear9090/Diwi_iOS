//
//  TierPricingViewController.swift
//  Diwi
//
//  Created by David Tong on 1/21/22.
//  Copyright © 2022 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import StoreKit

class TierPricingViewController: UIViewController {

    @IBOutlet private weak var basePlanView: UIView!
    @IBOutlet private weak var proPlanView: UIView!
    @IBOutlet private weak var chooseBasePlanButton: UIButton!
    @IBOutlet private weak var chooseProPlanButton: UIButton!
    @IBOutlet private weak var selectedBasePlanImageView: UIImageView!
    @IBOutlet private weak var selectedProPlanImageView: UIImageView!
    @IBOutlet private var ticksBasePlanImageView: [UIImageView]!
    @IBOutlet private var tipsBasePlanLabel: [UILabel]!
    @IBOutlet private var ticksProPlanImageView: [UIImageView]!
    @IBOutlet private var tipsProPlanLabel: [UILabel]!
    @IBOutlet private weak var upgradeProfileLabel: UILabel!
    @IBOutlet private weak var diwiBaseLabel: UILabel!
    @IBOutlet private weak var diwiProLabel: UILabel!
    @IBOutlet private weak var perMonthLabel: UILabel!

    public var premiumProduct : SKProduct?
    // MARK: Private
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupView()
        selectedBasePlan()
    }

    // MARK: Helper methods

    func setupNavBar() {
        if #available(iOS 13.0, *) {
            let buttonAppearance = UIBarButtonItemAppearance()
            buttonAppearance.configureWithDefault(for: .plain)
            buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]

            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = UIColor.black
            navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

            navigationBarAppearance.backButtonAppearance = buttonAppearance
            navigationBarAppearance.buttonAppearance = buttonAppearance
            navigationBarAppearance.doneButtonAppearance = buttonAppearance

            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            navigationController?.navigationBar.compactAppearance = navigationBarAppearance
            navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        } else {
            navigationController?.navigationBar.barTintColor = UIColor.black
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.tintColor = .white
        }
        navigationController?.navigationBar.tintColor = .white
        self.navigationController?.hideHairline()
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

    private func setupView() {

        if Purchases.default.hasFreePlan {
            basePlanView.removeFromSuperview()
        }

        chooseBasePlanButton.roundAllCorners(radius: chooseBasePlanButton.frame.height/2)
        chooseProPlanButton.roundAllCorners(radius: chooseProPlanButton.frame.height/2)
        chooseBasePlanButton.isHidden = true
        chooseProPlanButton.isHidden = true
        basePlanView.roundAllCorners(radius: 4, borderColor: UIColor(hex: Colors.pinkColor))
        proPlanView.roundAllCorners(radius: 4, borderColor: UIColor(hex: Colors.pinkColor))

        let tapGestureBasePlan = UITapGestureRecognizer(target: self, action: #selector(selectedBasePlan))
        basePlanView.isUserInteractionEnabled = true
        basePlanView.addGestureRecognizer(tapGestureBasePlan)

        let tapGestureProPlan = UITapGestureRecognizer(target: self, action: #selector(selectedProPlan))
        proPlanView.isUserInteractionEnabled = true
        proPlanView.addGestureRecognizer(tapGestureProPlan)

        chooseBasePlanButton.rx.tap.bind { [unowned self] in
            self.basePlanView.removeFromSuperview()
            Purchases.default.hasFreePlan = true
        }.disposed(by:self.disposeBag)

        chooseProPlanButton.rx.tap.bind { [unowned self] in
            if let productIdentifier = self.premiumProduct?.productIdentifier {
                Purchases.default.purchaseProduct(productIdentifier).subscribe(onNext: { (isSuccess) in
                    self.showMessage("You have full access!\nEnjoy your Diwi")
                    self.proPlanView.removeFromSuperview()
                    self.basePlanView.removeFromSuperview()
                }, onError: { (error) in
                    self.showMessage("We could not verify eligibility for this upgrade.")
                }).disposed(by: disposeBag)
            }
        }.disposed(by:self.disposeBag)
    }

    @IBAction func onCloseClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private func showMessage(_ msg: String) {
        let alert = UIAlertController(title: "Diwi", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

}
