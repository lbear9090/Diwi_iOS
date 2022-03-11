//
//  ContactCell.swift
//  Diwi
//
//  Created by Dominique Miller on 3/26/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import Kingfisher

class ContactCell: UITableViewCell {
    static var identifier: String = "Cell"
    
    // MARK: - view props
    let nameLabel = UILabel()
    let divider   = UIView()
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let deleteButton = UIButton()
    
    // MARK: - internal props
    var contact: Tag?
    var showDeleteButton = false {
        didSet {
            if showDeleteButton {
                setupDeleteButton()
            }
        }
    }
    
    var selectedForDeletion = false {
        didSet {
            if selectedForDeletion {
                rotateDeleteButton(rotation: 0.8)
            } else {
                rotateDeleteButton(rotation: 0)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        // remove previous images
        resetView()
        setupNameLabel()
        setupDivider()
        
        if hasImages() && imagesCount() > 3 {
            setupScroller()
            setupImages()
        } else if hasImages() && imagesCount() < 4 {
            setupStackViewWithoutScroller()
            setupImages()
        }
    }
    
    private func resetView() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        nameLabel.removeFromSuperview()
    }
    
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        if let contact = self.contact, let name = contact.title {
            nameLabel.text = name
        }
        nameLabel.textColor = UIColor.Diwi.barney
        nameLabel.font = UIFont.Diwi.address
        
        addSubview(nameLabel)
        
        if hasImages() {
            nameConstraintsWithImages()
        } else {
            nameConstraintsWithNoImages()
        }
    }
    
    private func nameConstraintsWithImages() {
       NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 11)
       ])
    }
    
    private func nameConstraintsWithNoImages() {
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupScroller() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        scrollView.addSubview(stackView)
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor),
            
            scrollView.heightAnchor.constraint(equalToConstant: 110),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -10),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10)
        ])
    }
    
    private func setupStackViewWithoutScroller() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 110),
            stackView.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10)
        ])
    }
    
    private func setupDivider() {
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor.Diwi.azure
        
        addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.leftAnchor.constraint(equalTo: leftAnchor),
            divider.rightAnchor.constraint(equalTo: rightAnchor),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func setupDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage.Diwi.removePinkIcon, for: .normal)
               
        addSubview(deleteButton)
               
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 28),
            deleteButton.heightAnchor.constraint(equalToConstant: 28),
            deleteButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            deleteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -28)
            ])
    }
    
    private func rotateDeleteButton(rotation: CGFloat) {
        UIView.animate(withDuration:0.2,
                       animations: {
            self.deleteButton.transform = CGAffineTransform(rotationAngle: rotation)
        })
    }
    
    private func setupImages() {
        guard let images = contact?.images else { return }
        
        for image in images {
            let box = UIImageView()
            box.translatesAutoresizingMaskIntoConstraints = false
            box.backgroundColor = UIColor.Diwi.gray
            box.layer.cornerRadius = 19
            box.contentMode = .scaleAspectFill
            box.clipsToBounds = true
            box.kf.setImage(with: URL(string: image), options: [])
            
            stackView.addArrangedSubview(box)
            
            NSLayoutConstraint.activate([
                box.widthAnchor.constraint(equalToConstant: 98),
                box.heightAnchor.constraint(equalToConstant: 110),
            ])
        }
    }
    
    private func hasImages() -> Bool {
        if let contact = self.contact, contact.hasImages() {
            return true
        } else {
            return false
        }
    }
    
    private func imagesCount() -> Int {
        guard let images = contact?.images else { return 0}
        return images.count
    }
}
