//
//  StartAddEventViewController.swift
//  Diwi
//
//  Created by Jae Lee on 10/22/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class StartAddEventViewController: UIViewController {
    let header = UIView()
    let navTitle = UILabel()
    let backIcon = UIButton()
    let nextButton = UIButton()
    let bodyLabel = UILabel()
    let subLabel = UILabel()
    
    // MARK: - internal props
    weak var coordinator: MainCoordinator?
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    

}

extension StartAddEventViewController {
    private func setupBindings() {
        backIcon.rx.tap.bind {
            self.coordinator?.popController()
        }.disposed(by: disposeBag)
        
        nextButton.rx.tap.bind {
            self.nextButton.buttonPressedAnimation {
                self.coordinator?.chooseNewEventDate()
            }
        }.disposed(by: disposeBag)
    }
}

extension StartAddEventViewController {
    private func setupView() {
        view.backgroundColor = UIColor.white
        setupHeader()
        setupNav()
        setupBodyLabel()
        setupSubLabel()
        setupNextButton()
    }
    
    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = UIColor.Diwi.yellow
        view.backgroundColor = UIColor.white
        view.addSubview(header)
        
        var height: NSLayoutConstraint
        if hasNotch() {
            height = header.heightAnchor.constraint(equalToConstant: 90)
        }
        else {
            height = header.heightAnchor.constraint(equalToConstant: 60)
        }
        NSLayoutConstraint.activate([
            header.leftAnchor.constraint(equalTo: view.leftAnchor),
            header.rightAnchor.constraint(equalTo: view.rightAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor),
            height
            ])
        
    }
    private func setupNav() {
        backIcon.translatesAutoresizingMaskIntoConstraints = false
        backIcon.setImage(UIImage.Diwi.backIconWhite, for: .normal)
        header.addSubview(backIcon)

        var paddingTop = CGFloat(25)
        if hasNotch() {
            paddingTop += 30
        }

        NSLayoutConstraint.activate([
            backIcon.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            backIcon.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10),
            backIcon.widthAnchor.constraint(equalToConstant: 25),
            backIcon.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        navTitle.translatesAutoresizingMaskIntoConstraints = false
        navTitle.textColor = UIColor.white
        navTitle.text = TextContent.Labels.addEvent
        navTitle.font = UIFont.Diwi.titleBold
        header.addSubview(navTitle)
        
        NSLayoutConstraint.activate([
            navTitle.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            navTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor),
        ])
    }
    
    private func setupBodyLabel() {
        bodyLabel.textColor = UIColor.Diwi.barney
        bodyLabel.font =  UIFont.Diwi.h3
        bodyLabel.numberOfLines = 2
        bodyLabel.textAlignment = .center
        bodyLabel.text = TextContent.Labels.startBy
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bodyLabel)
        NSLayoutConstraint.activate([
            bodyLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -178),
            bodyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bodyLabel.heightAnchor.constraint(equalToConstant: 90),
            bodyLabel.widthAnchor.constraint(equalToConstant: 340),
        ])
        
    }
    private func setupSubLabel() {
        subLabel.textColor = UIColor.Diwi.brownishGrey
        subLabel.font =  UIFont.Diwi.floatingButton
        subLabel.numberOfLines = 1
        subLabel.textAlignment = .center
        subLabel.text = TextContent.Labels.pressButtonToAddEvent
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subLabel)
        NSLayoutConstraint.activate([
            subLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 0),
            subLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subLabel.heightAnchor.constraint(equalToConstant: 23),
            subLabel.widthAnchor.constraint(equalToConstant: 340),
        ])
    }
    
    private func setupNextButton() {
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setImage(UIImage.Diwi.rightArrowButton, for: .normal)
        nextButton.contentMode = .scaleAspectFit
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            nextButton.heightAnchor.constraint(equalToConstant: 59),
            nextButton.widthAnchor.constraint(equalToConstant: 59),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            nextButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
    }
}
