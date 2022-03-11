//
//  FKMediaPicker.swift
//  FansKick
//
//  Created by FansKick-Sunil on 27/10/2017.
//  Copyright © 2017 FansKick Dev. All rights reserved.
//

import UIKit

enum VerticalContenerAlignment {
    case top
    case bottom
    case center
    
}
let kTag = 11111

var isShown:Bool?

class MessageView: UIView {

    @objc class func hide(){
        
        let keyWindow = UIApplication.shared.keyWindow
        isShown = false
        
            let containerView = keyWindow?.viewWithTag(kTag)
            if containerView != nil {
                MessageView.tapAction()
            }
    }
    
    class func showMessage(message:String, time:Float){
        MessageView.showMessage(message: message, time: time, textAlignment: NSTextAlignment.center)
    }
    
    class func showMessage(message:String, time:Float, verticalAlignment:VerticalContenerAlignment) {
        MessageView.showMessage(message: message, time: time, textAlignment: NSTextAlignment.center, verticalAlignment: verticalAlignment)

    }
    
    class func showMessage(message:String, time:Float, textAlignment:NSTextAlignment) {
        
        MessageView.showMessage(message: message, time: time, textAlignment: textAlignment, verticalAlignment: VerticalContenerAlignment.center)
    }
    class func showMessage(message:String, time:Float, textAlignment:NSTextAlignment, verticalAlignment:VerticalContenerAlignment) {
        
        let keyWindow = UIApplication.shared.keyWindow
        
        let messageWindow = keyWindow?.viewWithTag(kTag)
        
        if messageWindow == nil {
            isShown = false
        }
        
        if !isShown! {
        
            isShown = true
            let containerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 40))
            containerView.tag = kTag
            keyWindow?.addSubview(containerView)
            
            let mesageLbl = UILabel.init()
            
            mesageLbl.text = message
            mesageLbl.textAlignment = textAlignment
            mesageLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
            mesageLbl.font = UIFont.boldSystemFont(ofSize: 15)
            mesageLbl.numberOfLines = 0
            mesageLbl.textColor = UIColor.black
            containerView.addSubview(mesageLbl)
            
            
            let paragraph = NSMutableParagraphStyle.init()
            paragraph.lineBreakMode = mesageLbl.lineBreakMode
            
            let attributs = [
                .font: mesageLbl.font,
                NSAttributedString.Key.paragraphStyle: paragraph
                ] as [AnyHashable : Any]
            
            let text = message as NSString
            
            var viewWidth = 300.0 as CGFloat
            
            if verticalAlignment != .center {
                viewWidth = (keyWindow?.frame.width)!
            } else {
                containerView.layer.cornerRadius = 8.0
            }
            
            let textSize =  text.boundingRect(with: CGSize.init(width: viewWidth - 10 , height:.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributs as? [NSAttributedString.Key : Any], context: nil)
            
            if verticalAlignment == .center {
                containerView.frame = CGRect.init(x: 0, y: 0, width: viewWidth, height: textSize.height+10)
                mesageLbl.frame  = CGRect.init(x: 5, y: 5, width: containerView.frame.width - 10, height: containerView.frame.height - 10)

                containerView.center = (keyWindow?.center)!
                containerView.alpha = 0

                UIView.animate(withDuration: 0.5, animations: {
                    
                        containerView.alpha = 1
                        
                }) { (finished) in
                    containerView.alpha = 1
    
                    }
                
            } else if verticalAlignment == .top{
                containerView.frame = CGRect.init(x: 0, y: -(textSize.height + 30), width: viewWidth, height: textSize.height+30)
                
                mesageLbl.frame  = CGRect.init(x: 5, y: 25, width: containerView.frame.width - 10, height: containerView.frame.height - 30)
                containerView.alpha = 0

                UIView.animate(withDuration: 0.5, animations: {
                    containerView.center = CGPoint.init(x: containerView.frame.width/2, y: (containerView.frame.height/2))
                    containerView.alpha = 1

                }, completion: { (finished) in
                    containerView.center = CGPoint.init(x: containerView.frame.width/2, y: containerView.frame.height/2)
                    containerView.alpha = 1

                })
                
            } else if verticalAlignment == .bottom{
                containerView.frame = CGRect.init(x: 0, y: (keyWindow?.frame.height)!, width: viewWidth, height: textSize.height+30)
                
                mesageLbl.frame  = CGRect.init(x: 5, y: 5, width: containerView.frame.width - 10, height: containerView.frame.height - 30)
                containerView.alpha = 0

                UIView.animate(withDuration: 0.5, animations: {
                    containerView.center = CGPoint.init(x: containerView.frame.width/2, y: (keyWindow?.frame.height)! -  containerView.frame.height/2)
                    containerView.alpha = 1

                }, completion: { (finished) in
                    containerView.center = CGPoint.init(x: containerView.frame.width/2, y: (keyWindow?.frame.height)! -  containerView.frame.height/2)
                    containerView.alpha = 1
                })
                
            }
            
            containerView.layer.shadowColor = UIColor.darkGray.cgColor
            
            containerView.layer.shadowOffset = CGSize.init(width: 3, height: 3)
            containerView.layer.shadowRadius = 3
            containerView.layer.shadowOpacity = 0.8
            
            keyWindow?.bringSubviewToFront(containerView)
            containerView.backgroundColor = .white//UIColor.RGB(r: 14, g: 116, b: 231, alpha: 1.0)
            
            if time > 0 {
                self.perform(#selector(MessageView.hide), with: nil, afterDelay: TimeInterval(time))
                
            }
            
            let gesture = UITapGestureRecognizer.init(target: self, action: #selector(MessageView.tapAction))
            containerView.addGestureRecognizer(gesture)
        }
    }
    
  @objc class func tapAction() {
        
        let keyWindow = UIApplication.shared.keyWindow
        isShown = false
        
        UIView.animate(withDuration: 0.5, animations: { 
            let containerView = keyWindow?.viewWithTag(kTag)
           
            if containerView != nil {
                containerView?.alpha = 0

            }
        }) { (finished) in
            let containerView = keyWindow?.viewWithTag(kTag)
            if containerView != nil {
                containerView?.removeFromSuperview()
                
            }
        }
    }
}
