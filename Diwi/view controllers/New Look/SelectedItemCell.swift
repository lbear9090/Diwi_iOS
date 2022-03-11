//
//  SelectedItemCell.swift
//  Diwi
//
//  Created by Apple on 02/11/2021.
//  Copyright © 2021 Trim Agency. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class SelectedItemCell: UICollectionViewCell{
    
    static var identifier: String = "Cell"
   
    
     var selectedItem: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "whatBackground")
         return imageView
    }()
    
    var blackView: UIView = {
        let blackView = UIView()
       return blackView
    }()
    
    var deleteBtn: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "delete")
        return imageView
    }()
    
    var saveBtn: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bookMark")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black
        setupImageView()
        setupView()
        setupSaveBtn()
        setupDeleteBtn()
    }
    
    
    
    private func setupImageView(){
        selectedItem.translatesAutoresizingMaskIntoConstraints = false
        selectedItem.backgroundColor = UIColor.Diwi.gray
        selectedItem.layer.cornerRadius = 10
        selectedItem.contentMode = .scaleAspectFill
        selectedItem.clipsToBounds = true
        
        contentView.addSubview(selectedItem)
        
        NSLayoutConstraint.activate([
            
            selectedItem.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -200),
            selectedItem.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            selectedItem.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectedItem.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 40),
            selectedItem.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -40)
            ])
    }
    
    private func setupView(){
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.backgroundColor = .black.withAlphaComponent(0.5)
        blackView.layer.cornerRadius =  10
        blackView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        blackView.clipsToBounds = true
        
        contentView.addSubview(blackView)
        
        NSLayoutConstraint.activate([
            blackView.leftAnchor.constraint(equalTo: selectedItem.leftAnchor),
            blackView.rightAnchor.constraint(equalTo: selectedItem.rightAnchor),
//            blackView.widthAnchor.constraint(equalToConstant: 300),
            blackView.heightAnchor.constraint(equalToConstant: 60),
            blackView.bottomAnchor.constraint(equalTo: selectedItem.bottomAnchor),
//            blackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ])
    }
    
    private func setupSaveBtn(){
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.contentMode = .scaleAspectFit
        saveBtn.clipsToBounds = true
        
        blackView.addSubview(saveBtn)
        
        NSLayoutConstraint.activate([
            saveBtn.widthAnchor.constraint(equalToConstant: 40),
            saveBtn.heightAnchor.constraint(equalToConstant: 40),
            saveBtn.bottomAnchor.constraint(equalTo: blackView.bottomAnchor, constant: -10),
            saveBtn.leftAnchor.constraint(equalTo: blackView.leftAnchor, constant: 20),
            ])
    }
    
    private func setupDeleteBtn(){
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.contentMode = .scaleAspectFill
        deleteBtn.clipsToBounds = true
        
        blackView.addSubview(deleteBtn)
        
        NSLayoutConstraint.activate([
            deleteBtn.widthAnchor.constraint(equalToConstant: 40),
            deleteBtn.heightAnchor.constraint(equalToConstant: 40),
            deleteBtn.bottomAnchor.constraint(equalTo: blackView.bottomAnchor, constant: -10),
            deleteBtn.rightAnchor.constraint(equalTo: blackView.rightAnchor, constant: -20),
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib(){
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

