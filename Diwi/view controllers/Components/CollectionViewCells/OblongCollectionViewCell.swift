//
//  OblongCell.swift
//  Diwi
//
//  Created by Dominique Miller on 4/1/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OblongCollectionViewCell: UICollectionViewCell {
    var name = UILabel()
    var button = UIButton()
    var id:Int?
    var title: String = ""
    let disposeBag = DisposeBag()
    var viewMode: ViewingMode = .view {
        didSet {
            if viewMode == .view {
                button.isHidden = true
            } else if viewMode == .edit {
                button.isHidden = false
            }
        }
    }
    
    var remove: ((_ title: String, _ id: Int?) -> Void)?
    
    override init(frame: CGRect) {
      super.init(frame: frame)
        contentView.roundAllCorners(radius: 32/2)
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 0.3
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        setupName()
        setupButton()
    }
    
    fileprivate func setupName() {
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = UIFont.Diwi.floatingButton
        name.textColor = UIColor.Diwi.azure
        contentView.addSubview(name)
        NSLayoutConstraint.activate([
            name.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant:13),
            name.topAnchor.constraint(equalTo: contentView.topAnchor),
            name.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            name.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    fileprivate func setupButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.Diwi.removePinkIcon, for: .normal)
    
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: name.rightAnchor),
            button.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:0),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        button.rx.tap.bind { [unowned self] in
            self.remove?(self.title, self.id)
        }.disposed(by: disposeBag)
    }
    
    
    func configure(with title: String, id: Int?, mode: ViewingMode = .view) {
        self.id = id
        name.text = title
        viewMode = mode
    }
}

