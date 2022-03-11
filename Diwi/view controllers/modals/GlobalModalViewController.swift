//
//  SaveItemModalViewController.swift
//  Diwi
//
//  Created by Dominique Miller on 9/4/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class GlobalModalViewController: UIViewController {
    
    // MARK: - View props
    let leftButton        = UIButton()
    let rightButton       = UIButton()
    let contentContainer  = UIView()
    let header            = UIView()
    let headerText        = UILabel()
    let itemImage         = UIImageView()
    let closeBtn          = UIButton()
    let cheersIcon        = UIImageView()
    let cheersTextBox     = UIView()
    let cheersTextBoxText = UILabel()
    var spinnerView       = UIView()
    
    // MARK: - Internal props
    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?
    var closeButtonAction: (() -> Void)?
    let disposeBag = DisposeBag()
    var workflow: Workflow {
        return viewModel.getCurrentWorkflow()
    }
    var viewModel: GlobalModalViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupView()
        setupBindings()
    }
}

// MARK: - SetupView
extension GlobalModalViewController {
    private func setupView() {
        view.gradientBackground(startColor: UIColor.gray, endColor: UIColor.Diwi.fadedGray)
        setupCloseBtn()
        setupContent()
        setupLeftButton()
        setupRightButton()
        setupSpinner()
    }
    
    private func setupCloseBtn() {
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.setImage(UIImage.Diwi.closeBtn, for: .normal)
        
        view.addSubview(closeBtn)
        
        NSLayoutConstraint.activate([
            closeBtn.heightAnchor.constraint(equalToConstant: 28),
            closeBtn.widthAnchor.constraint(equalToConstant: 28),
            closeBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10)
            ])
    }
    
    private func setupContentContainer() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.layer.cornerRadius = 20
        contentContainer.backgroundColor = .white
        contentContainer.clipsToBounds = true
        
        view.addSubview(contentContainer)
        
        NSLayoutConstraint.activate([
            contentContainer.heightAnchor.constraint(equalToConstant: 450),
            contentContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 46),
            contentContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -46)
            ])
    }
    
    private func setupContent() {
        switch workflow {
        case .noEventScheduledOnDay:
            cheersSetup()
        case .removeContacts:
            cheersSetup()
        case .removeEventFromCalendar:
            cheersSetup()
        case .removeItems:
            cheersSetup()
        case .removeLooks:
            cheersSetup()
        default:
            defaultSetup()
        }
    }
    
    private func cheersSetup() {
        setupCheersBox()
        setupCheersText()
        setupCheersIcon()
    }
    
    private func defaultSetup() {
        setupContentContainer()
        setupHeader()
        setupHeaderText()
        setupItemImage()
    }
    
    private func setupCheersBox() {
        cheersTextBox.translatesAutoresizingMaskIntoConstraints = false
        cheersTextBox.backgroundColor = .white
        cheersTextBox.layer.cornerRadius = 15
        
        view.addSubview(cheersTextBox)
        
        NSLayoutConstraint.activate([
            cheersTextBox.widthAnchor.constraint(equalToConstant: 282),
            cheersTextBox.heightAnchor.constraint(equalToConstant: 187),
            cheersTextBox.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cheersTextBox.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupCheersText() {
        cheersTextBoxText.translatesAutoresizingMaskIntoConstraints = false
        cheersTextBoxText.font = UIFont.Diwi.textField
        cheersTextBoxText.textColor = .black
        cheersTextBoxText.textAlignment = .center
        cheersTextBoxText.numberOfLines = 0
        
        cheersTextBox.addSubview(cheersTextBoxText)
        
        NSLayoutConstraint.activate([
            cheersTextBoxText.widthAnchor.constraint(equalToConstant: 188),
            cheersTextBoxText.heightAnchor.constraint(equalToConstant: 56),
            cheersTextBoxText.bottomAnchor.constraint(equalTo: cheersTextBox.bottomAnchor, constant: -53),
            cheersTextBoxText.centerXAnchor.constraint(equalTo: cheersTextBox.centerXAnchor)
        ])
    }
    
    private func setupCheersIcon() {
        cheersIcon.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cheersIcon)
        
        NSLayoutConstraint.activate([
            cheersIcon.heightAnchor.constraint(equalToConstant: 101),
            cheersIcon.widthAnchor.constraint(equalToConstant: 101),
            cheersIcon.centerXAnchor.constraint(equalTo: cheersTextBox.centerXAnchor),
            cheersIcon.centerYAnchor.constraint(equalTo: cheersTextBox.topAnchor)
        ])
        
    }
    
    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = UIColor.Diwi.azure
        
        contentContainer.addSubview(header)
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            header.leftAnchor.constraint(equalTo: contentContainer.leftAnchor),
            header.heightAnchor.constraint(equalToConstant: 53),
            header.rightAnchor.constraint(equalTo: contentContainer.rightAnchor)
            ])
    }
    
    private func setupHeaderText() {
        headerText.translatesAutoresizingMaskIntoConstraints = false
        headerText.textColor = .white
        headerText.textAlignment = .center
        headerText.font = UIFont.Diwi.textField
        headerText.lineBreakMode = .byWordWrapping
        headerText.numberOfLines = 0
        
        contentContainer.addSubview(headerText)
        
        NSLayoutConstraint.activate([
            headerText.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            headerText.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            headerText.widthAnchor.constraint(equalToConstant: 224),
            headerText.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    private func setupItemImage() {
        itemImage.translatesAutoresizingMaskIntoConstraints = false
        itemImage.backgroundColor = .gray
        itemImage.contentMode = .scaleAspectFill
        
        contentContainer.addSubview(itemImage)
        
        NSLayoutConstraint.activate([
            itemImage.topAnchor.constraint(equalTo: header.bottomAnchor),
            itemImage.leftAnchor.constraint(equalTo: contentContainer.leftAnchor),
            itemImage.rightAnchor.constraint(equalTo: contentContainer.rightAnchor),
            itemImage.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
            ])
    }
    
    private func setupLeftButton() {
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.setTitleColor(UIColor.Diwi.barney, for: .normal)
        leftButton.backgroundColor = .white
        leftButton.titleLabel?.font = UIFont.Diwi.textField
        
        if workflow == .addEvent {
            leftButton.isHidden = true
        }
        
        view.addSubview(leftButton)
        
        NSLayoutConstraint.activate([
            leftButton.heightAnchor.constraint(equalToConstant: 60),
            leftButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            leftButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
            ])
    }
    
    private func setupRightButton() {
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.setTitleColor(.white, for: .normal)
        rightButton.backgroundColor = UIColor.Diwi.barney
        rightButton.titleLabel?.font = UIFont.Diwi.textField
        
        if workflow == .addEvent {
            rightButton.isHidden = true
        }
        
        view.addSubview(rightButton)
        
        NSLayoutConstraint.activate([
            rightButton.heightAnchor.constraint(equalToConstant: 60),
            rightButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            rightButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
            ])
    }
    
    private func setupSpinner() {
        spinnerView = UIView.init(frame: view.bounds)
    }
}

// MARK: - Setup bindings
extension GlobalModalViewController {
    private func setupBindings() {
        viewModel.itemImageUrl
            .subscribe(onNext: { [unowned self] imageUrl in
                if !imageUrl.isEmpty {
                    self.itemImage.kf.setImage(with: URL(string: imageUrl), options: [])
                }
            }).disposed(by: disposeBag)
        
        viewModel.errorMsg
            .subscribe(onNext: { [unowned self] (value) in
                if !value.isEmpty {
                    self.presentError(value)
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
                }
                else {
                    self.removeSpinner(spinner: self.spinnerView)
                }
            }).disposed(by: disposeBag)
        
        viewModel.success
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.rightButtonAction?()
                }
            }).disposed(by: disposeBag)
        
        viewModel.cheersIcon
            .subscribe(onNext: { [unowned self] iconImage in
                self.cheersIcon.image = iconImage
        }).disposed(by: disposeBag)

        closeBtn.rx.tap.bind { [unowned self] in
            self.closeButtonAction?()
            }.disposed(by: disposeBag)
        
        leftButton.rx.tap.bind { [unowned self] in
            self.leftButtonAction?()
            }.disposed(by: disposeBag)
        
        rightButton.rx.tap.bind { [unowned self] in
            self.viewModel.handleRightButtonPress()
        }.disposed(by: disposeBag)
        
        viewModel.leftButtonText
            .asObservable()
            .map { $0 }
            .bind(to: self.leftButton.rx.title(for: .normal))
            .disposed(by:self.disposeBag)
        
        viewModel.rightButtonText
            .asObservable()
            .map { $0 }
            .bind(to: self.rightButton.rx.title(for: .normal))
            .disposed(by:self.disposeBag)
        
        viewModel.headerText
            .asObservable()
            .map { $0 }
            .bind(to: self.headerText.rx.text)
            .disposed(by:self.disposeBag)
        
        viewModel.cheersTextBoxText
            .asObservable()
            .map { $0 }
            .bind(to: self.cheersTextBoxText.rx.text)
            .disposed(by:self.disposeBag)
    }
}
