//
//  AddAttireImageViewController.swift
//  Diwi
//
//  Created by Jae Lee on 11/11/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddAttireImageViewController: UIViewController {
    var exitButton = UIButton()
    var takePhotoButton = UIButton()
    var addFromClosetButton = UIButton()
    
    var launchCamera: (() -> Void)?
    var launchCloset: (() -> Void)?
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setup()
        setupBindings()
    }

}


extension AddAttireImageViewController {
    private func setupBindings() {
        takePhotoButton.rx.tap.bind {
            self.launchCamera?()
        }
        .disposed(by: disposeBag)
        
        exitButton.rx.tap.bind {
            self.dismiss(animated: true, completion: nil)
        }
        .disposed(by: disposeBag)
        
    }
}

extension AddAttireImageViewController {
    private func setup() {
        setupExitButton()
        setupTakePhotoButton()
        setupAddFromPhotoButton()
    }
    private func setupExitButton() {
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.setImage(UIImage.Diwi.closeBtn, for: .normal)
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            exitButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 30),
            exitButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    private func setupTakePhotoButton() {
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.titleLabel?.font = UIFont.Diwi.floatingButton
        takePhotoButton.setTitle(TextContent.Buttons.takePhoto, for: .normal)
        takePhotoButton.setTitleColor(.white, for: .normal)
        takePhotoButton.backgroundColor = UIColor.Diwi.barney
        takePhotoButton.roundAllCorners(radius: 25)
        view.addSubview(takePhotoButton)
        NSLayoutConstraint.activate([
            takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takePhotoButton.heightAnchor.constraint(equalToConstant: 50),
            takePhotoButton.widthAnchor.constraint(equalToConstant: 315),
            takePhotoButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
        ])
       }
       
    private func setupAddFromPhotoButton() {
        addFromClosetButton.translatesAutoresizingMaskIntoConstraints = false
        addFromClosetButton.titleLabel?.font = UIFont.Diwi.floatingButton
        addFromClosetButton.setTitle(TextContent.Buttons.addFromCloset, for: .normal)
        addFromClosetButton.setTitleColor(.white, for: .normal)
        addFromClosetButton.backgroundColor = UIColor.Diwi.barney
        addFromClosetButton.roundAllCorners(radius: 25)
        view.addSubview(addFromClosetButton)
        NSLayoutConstraint.activate([
            addFromClosetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addFromClosetButton.heightAnchor.constraint(equalToConstant: 50),
            addFromClosetButton.widthAnchor.constraint(equalToConstant: 315),
            addFromClosetButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 10),
        ])
    }
}
