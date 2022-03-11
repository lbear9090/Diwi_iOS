//
//  TimePickerViewController.swift
//  Diwi
//
//  Created by Jae Lee on 11/4/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class TimePickerViewController: UIViewController {
    var timePicker = UIDatePicker()
    var exitButton = UIButton()

    
    var finished: ((Date) -> Void)?

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setup()
        setupBindings()
    }

}
extension TimePickerViewController {
    private func setupBindings() {
     
        exitButton.rx.tap.bind {
            self.finished?(self.timePicker.date)
        }
        .disposed(by: disposeBag)
        
    }
}

extension TimePickerViewController {
    private func setup() {
        setupPickerView()
        setupExitButton()

    }
    private func setupPickerView() {
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.datePickerMode = .time
        timePicker.backgroundColor = .white
        timePicker.roundAllCorners(radius: 10)
        view.addSubview(timePicker)
        
        NSLayoutConstraint.activate([
            timePicker.widthAnchor.constraint(equalToConstant: 282),
            timePicker.heightAnchor.constraint(equalToConstant: 378),
            timePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
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
    
   
}
