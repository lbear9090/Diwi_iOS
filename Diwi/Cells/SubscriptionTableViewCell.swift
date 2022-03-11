//
//  SubscriptionTableViewCell.swift
//  Diwi
//
//  Created by Apple on 17/11/2021.
//  Copyright © 2021 Trim Agency. All rights reserved.
//

import UIKit
import Kingfisher

class SubscriptionTableViewCell: UITableViewCell {
    
    let view = UIView()
    let lblAmount = UILabel()
    let img = UIImageView()
    let imgScnd = UIImageView()
    let imgThrd = UIImageView()
    let imgFrth = UIImageView()
    let lblFirst = UILabel()
    let lblSecond = UILabel()
    let lblThird = UILabel()
    let lblFourth = UILabel()
    let btnChoose = AppButton()
    static var identifier: String = "Cell"
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setupView(){
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
//            view.widthAnchor.constraint(equalToConstant: 300),
            view.heightAnchor.constraint(equalToConstant: 280),
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.backgroundColor = .white
//        img.layer.borderWidth = 1.0
        img.layer.masksToBounds = false
        img.layer.borderColor = UIColor.white.cgColor
        img.layer.cornerRadius = img.frame.size.width / 2
        view.addSubview(img)
        
        NSLayoutConstraint.activate([
            img.topAnchor.constraint(equalTo: view.topAnchor, constant: 33),
            img.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            img.heightAnchor.constraint(equalToConstant: 45),
            img.widthAnchor.constraint(equalToConstant: 45),
            
            ])
        
        lblFirst.translatesAutoresizingMaskIntoConstraints = false
        lblFirst.font = UIFont.Diwi.title
        lblFirst.textColor = .black
        lblFirst.text = "DIWI Base Plan"

        view.addSubview(lblFirst)
        
        NSLayoutConstraint.activate([
            lblFirst.topAnchor.constraint(equalTo: view.topAnchor, constant: 47),
//            lblFirst.centerXAnchor.constraint(equalTo: img.centerXAnchor, constant: 45),
            lblFirst.leftAnchor.constraint(equalTo: img.rightAnchor, constant: 12)
            ])
        
        lblAmount.translatesAutoresizingMaskIntoConstraints = false
        lblAmount.font = UIFont.Diwi.title
        lblAmount.textColor = .black
        lblAmount.text = "FREE"

        view.addSubview(lblAmount)
        
        NSLayoutConstraint.activate([
            lblAmount.topAnchor.constraint(equalTo: view.topAnchor, constant: 47),
            lblAmount.leftAnchor.constraint(equalTo: lblFirst.rightAnchor, constant: 50)
            ])
        
        imgScnd.translatesAutoresizingMaskIntoConstraints = false
        imgScnd.contentMode = .scaleAspectFill
        
        view.addSubview(imgScnd)
        
        NSLayoutConstraint.activate([
            imgScnd.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 10),
            imgScnd.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            imgScnd.heightAnchor.constraint(equalToConstant: 30),
            imgScnd.widthAnchor.constraint(equalToConstant: 30)
            ])
        
        lblSecond.translatesAutoresizingMaskIntoConstraints = false
        lblSecond.font = UIFont.Diwi.text
        lblSecond.textColor = .black
        lblSecond.text = "7 looks total, 7 equals to 1 week of looks"

        view.addSubview(lblSecond)
        
        NSLayoutConstraint.activate([
            lblSecond.topAnchor.constraint(equalTo: lblFirst.bottomAnchor, constant: 28),
//            lblFirst.centerXAnchor.constraint(equalTo: imgScnd.centerXAnchor),
            lblSecond.leftAnchor.constraint(equalTo: imgScnd.rightAnchor, constant: 8)
            ])
        
        imgThrd.translatesAutoresizingMaskIntoConstraints = false
        imgThrd.contentMode = .scaleAspectFill
        
        view.addSubview(imgThrd)
        
        NSLayoutConstraint.activate([
            imgThrd.topAnchor.constraint(equalTo: imgScnd.bottomAnchor, constant: 10),
            imgThrd.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            imgThrd.heightAnchor.constraint(equalToConstant: 30),
            imgThrd.widthAnchor.constraint(equalToConstant: 30)
            ])
        
        lblThird.translatesAutoresizingMaskIntoConstraints = false
        lblThird.font = UIFont.Diwi.text
        lblThird.textColor = .black
        lblThird.text = "Can upload only 1 video"

        view.addSubview(lblThird)
        
        NSLayoutConstraint.activate([
            lblThird.topAnchor.constraint(equalTo: lblSecond.bottomAnchor, constant: 21),
//            lblFirst.centerXAnchor.constraint(equalTo: img.centerXAnchor, constant: 45),
            lblThird.leftAnchor.constraint(equalTo: imgThrd.rightAnchor, constant: 8)
            ])
        
//        imgFrth.translatesAutoresizingMaskIntoConstraints = false
//        imgFrth.contentMode = .scaleAspectFill
//
//        view.addSubview(imgFrth)
//
//        NSLayoutConstraint.activate([
//            imgFrth.topAnchor.constraint(equalTo: imgThrd.bottomAnchor, constant: 10),
//            imgFrth.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
//            imgFrth.heightAnchor.constraint(equalToConstant: 30),
//            imgFrth.widthAnchor.constraint(equalToConstant: 30)
//            ])
//
//        lblFourth.translatesAutoresizingMaskIntoConstraints = false
//        lblFourth.font = UIFont.Diwi.text
//        lblFourth.textColor = .black
//        lblFourth.text = "Lorem ipsum dolor sit amet, consectetur adipiscing"
//
//        view.addSubview(lblFourth)
//
//        NSLayoutConstraint.activate([
//            lblFourth.topAnchor.constraint(equalTo: lblThird.bottomAnchor, constant: 26 ),
////            lblFirst.centerXAnchor.constraint(equalTo: img.centerXAnchor, constant: 45),
//            lblFourth.leftAnchor.constraint(equalTo: imgFrth.rightAnchor, constant: 8)
//            ])
        
        btnChoose.translatesAutoresizingMaskIntoConstraints = false
        btnChoose.setTitle(TextContent.Buttons.choosePlan, for: .normal)
        btnChoose.titleLabel?.font = UIFont.Diwi.titleBold1
        btnChoose.setTitleColor( UIColor.Diwi.barney, for: .normal)
        btnChoose.EnableButton()
        btnChoose.roundAllCorners(radius: 30)
        btnChoose.isHidden = true
        
        view.addSubview(btnChoose)
        
        NSLayoutConstraint.activate([
            btnChoose.topAnchor.constraint(equalTo: imgThrd.bottomAnchor, constant: 25),
            btnChoose.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            btnChoose.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            btnChoose.heightAnchor.constraint(equalToConstant: 60),
//            btnChoose.widthAnchor.constraint(equalToConstant: 170),
        ])
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
