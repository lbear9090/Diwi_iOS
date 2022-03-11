//
//  searchResultCell.swift
//  Diwi
//
//  Created by Dominique Miller on 4/16/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    static var identifier: String = "Cell"
    
    let title    = UILabel()
    let label    = UILabel()
    let searchLabel    = UILabel()
    let underline = UIView()
    let searchTypeImage = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with result: Result) {
        guard let titleText = result.title,
        let labelText = result.label else { return }
        setupImage(with: result.searchType ?? .Search)
        //setupTitle(with: titleText)
        setupLabel(with: labelText, searchTitle: titleText)
        searchLabel.isHidden = true
        //title.isHidden = false
        label.isHidden = false
        if (result.searchType ?? .Search) == .Search
        {
            //title.isHidden = true
            label.isHidden = true
            searchLabel.isHidden = false
            setupSearchLabel(with: titleText)
        }
        
        setupUnderline()
    }
    
    private func setupImage(with type: SearchType) {
        searchTypeImage.translatesAutoresizingMaskIntoConstraints = false
        
        switch type {
        case .Look:
            searchTypeImage.image = UIImage.init(named: "camera-unselected")
        case .Contact:
            searchTypeImage.image = UIImage.init(named: "friendsIcon")
        case .Event:
            searchTypeImage.image = UIImage.init(named: "calendarIconGray")
        case .Clothing:
            searchTypeImage.image = UIImage.init(named: "camera-unselected")
        case .Search:
            searchTypeImage.image = UIImage.init(named: "searchGrey")
        }
        
        addSubview(searchTypeImage)
        
        NSLayoutConstraint.activate([
            searchTypeImage.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            searchTypeImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 25),
            searchTypeImage.heightAnchor.constraint(equalToConstant: 32),
            searchTypeImage.widthAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    private func setupTitle(with text: String) {
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = text
        title.textColor  = UIColor.Diwi.barney
        title.font = UIFont.Diwi.placeHolder
        
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 65)
        ])
    }
    
    
    private func setupSearchLabel(with text: String) {
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        searchLabel.text = text
        searchLabel.textColor  = UIColor.Diwi.barney
        searchLabel.font = UIFont.Diwi.placeHolder

        addSubview(searchLabel)

        NSLayoutConstraint.activate([
            searchLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            searchLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 65)
        ])

        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Hello"
        title.textColor  = UIColor.Diwi.barney
        title.font = UIFont.Diwi.placeHolder

        addSubview(title)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 65)
        ])
    }
    
    private func setupLabel(with fulllText: String,searchTitle: String) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = fulllText
        label.textColor  = UIColor.Diwi.brownishGrey
        label.font = UIFont.Diwi.placeHolder

        addSubview(label)

        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 65)
        ])
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = searchTitle
        title.textColor  = UIColor.Diwi.barney
        title.font = UIFont.Diwi.placeHolder
        
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 65)
        ])
    }
    
    private func setupUnderline() {
        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = UIColor.Diwi.azure
        
        addSubview(underline)
        
        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 1),
            underline.bottomAnchor.constraint(equalTo: bottomAnchor),
            underline.leftAnchor.constraint(equalTo: leftAnchor, constant: 25),
            underline.rightAnchor.constraint(equalTo: rightAnchor, constant: -20)
        ])
    }
}
