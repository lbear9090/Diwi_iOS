//
//  RPicker.swift
//  FansKick
//
//  Created by FansKick-Raj on 13/10/2017.
//  Copyright © 2017 FansKick Dev. All rights reserved.
//

import UIKit

let pickerAnimationDuration: TimeInterval = 0.3
let viewTransperantTag: Int = 9099

//class RPicker: NSObject {
//
//    static let sharedInstance = RPicker()
//    fileprivate var dataArray: Array<String> = []
//
//    class func selectDate(title: String = "",
//                          hideCancel: Bool = false,
//                          datePickerMode: UIDatePicker.Mode = UIDatePicker.Mode.date,
//                          selectedDate: Date? = Date(),
//                          minDate: Date? = nil,
//                          maxDate: Date? = nil,
//                          didSelectDate : ((_ date: Date)->())?)  {
//
//        if let currentController = APPDELEGATE.window?.currentController {
//            if let bgView = currentController.view.viewWithTag(viewTransperantTag) {
//                return
//            }
//
//
//            let datePicker = UIDatePicker()
//            datePicker.datePickerMode = datePickerMode
//            datePicker.backgroundColor = UIColor.white
//
//            datePicker.minimumDate = minDate
//            datePicker.maximumDate = maxDate
//
//            if let selectedDate = selectedDate {
//                datePicker.date = selectedDate
//            } else {
//                datePicker.date = Date()
//            }
//
//            //Screen Size
//            let screenWidth = currentController.view.bounds.size.width
//            let screenHeight = currentController.view.bounds.size.height
//            let pickerHeight: CGFloat = 216
//
//            // Add background view
//
//            let closeFrame = CGRect(x: 0, y: screenHeight + 50, width: screenWidth, height: screenHeight)
//
//            let viewTransperant = UIView(frame: closeFrame)
//            viewTransperant.backgroundColor = UIColor.clear
//            //viewTransperant.alpha = 0.0
//            currentController.view.addSubview(viewTransperant)
//            viewTransperant.tag = viewTransperantTag
//
//            // Add date picker view
//
//            let pickerY = screenHeight - pickerHeight
//
//            let pickerFrame = CGRect(x: 0, y: pickerY, width: screenWidth, height: pickerHeight)
//            datePicker.frame = pickerFrame
//            viewTransperant.addSubview(datePicker)
//
//            // Add tool bar with done and cancel buttons
//            var toolBarFrame = CGRect(x: 0, y: pickerY, width: screenWidth, height: 40)
//            toolBarFrame.origin.y = pickerY - toolBarFrame.size.height
//
//            let toolBar = RToolBar(frame: toolBarFrame)
//            toolBar.addToolBar(hideCancelButton: hideCancel)
//            toolBar.title = title
//
//            viewTransperant.addSubview(toolBar)
//
//            // show picker
//            var openPickerFrame = viewTransperant.frame
//            openPickerFrame.origin.y = 0
//
//            UIView.animate(withDuration: <#T##TimeInterval#>, animations: <#T##() -> Void#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
//
//            UIView.animate(withDuration: pickerAnimationDuration, animations: {
//                viewTransperant.frame = openPickerFrame
//
//            }, completion: { (_) in
//                UIView.animate(withDuration: pickerAnimationDuration, animations: {
//                    viewTransperant.backgroundColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.6)
//                })
//            })
//
//            toolBar.didSelectDone = {
//                didSelectDate!(datePicker.date)
//                remove()
//            }
//
//            toolBar.didCancelled = {
//
//                remove()
//            }
//
//            func remove() {
//
//                UIView.animate(withDuration: pickerAnimationDuration, animations: {
//                    viewTransperant.backgroundColor = UIColor.clear
//
//                }, completion: { (_) in
//                    UIView.animate(withDuration: pickerAnimationDuration, animations: {
//                        viewTransperant.frame = closeFrame
//                    }, completion: { (_) in
//                        viewTransperant.removeFromSuperview()
//                    })
//                })
//            }
//        }
//    }
//
//    func selectOption(title: String = "",
//                      hideCancel: Bool = false,
//                      dataArray:Array<String>?,
//                      selectedIndex: Int?,
//                      vc:UIViewController,
//                      didSelectValue : ((_ value: String, _ atIndex: Int)->())?)  {
//
//        guard let dataArray = dataArray else {
//            print("Blank array")
//            return
//        }
//
//        self.dataArray = dataArray
//
//        let currentController = vc
//        if currentController.view.viewWithTag(viewTransperantTag) != nil {
//            return
//        }
//
//        let optionPicker = UIPickerView()
//        optionPicker.backgroundColor = UIColor.white
//        optionPicker.dataSource = self
//        optionPicker.delegate = self
//
//        if let selectedIndex = selectedIndex {
//
//            if (selectedIndex < dataArray.count) {
//                optionPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
//            }
//        }
//
//        //Screen Size
//        let screenWidth = currentController.view.bounds.size.width
//        let screenHeight = currentController.view.bounds.size.height
//        let pickerHeight: CGFloat = 216
//
//        // Add background view
//
//        let closeFrame = CGRect(x: 0, y: screenHeight + 50, width: screenWidth, height: screenHeight)
//
//        let viewTransperant = UIView(frame: closeFrame)
//        viewTransperant.backgroundColor = UIColor.clear
//        //viewTransperant.alpha = 0.0
//        currentController.view.addSubview(viewTransperant)
//        viewTransperant.tag = viewTransperantTag
//
//        // Add date picker view
//
//        let pickerY = screenHeight - pickerHeight
//
//        let pickerFrame = CGRect(x: 0, y: pickerY, width: screenWidth, height: pickerHeight)
//        optionPicker.frame = pickerFrame
//        viewTransperant.addSubview(optionPicker)
//
//        // Add tool bar with done and cancel buttons
//        var toolBarFrame = CGRect(x: 0, y: pickerY, width: screenWidth, height: 40)
//        toolBarFrame.origin.y = pickerY - toolBarFrame.size.height
//
//        let toolBar = RToolBar(frame: toolBarFrame)
//        toolBar.addToolBar(hideCancelButton: hideCancel)
//
//        toolBar.title = title
//
//        viewTransperant.addSubview(toolBar)
//
//        // show picker
//        var openPickerFrame = viewTransperant.frame
//        openPickerFrame.origin.y = 0
//
//        UIView.animate(withDuration: pickerAnimationDuration, animations: {
//            viewTransperant.frame = openPickerFrame
//
//        }, completion: { (_) in
//            UIView.animate(withDuration: pickerAnimationDuration, animations: {
//                viewTransperant.backgroundColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.6)
//            })
//        })
//
//        toolBar.didSelectDone = {
//
//            if let block = didSelectValue {
//
//                let selectedValueIndex = optionPicker.selectedRow(inComponent: 0)
//
//                block(dataArray[selectedValueIndex], selectedValueIndex)
//            }
//            remove()
//        }
//
//        toolBar.didCancelled = {
//
//            remove()
//        }
//
//
//        func remove() {
//
//            UIView.animate(withDuration: pickerAnimationDuration, animations: {
//                viewTransperant.backgroundColor = UIColor.clear
//
//            }, completion: { (_) in
//                UIView.animate(withDuration: pickerAnimationDuration, animations: {
//                    viewTransperant.frame = closeFrame
//                }, completion: { (_) in
//                    viewTransperant.removeFromSuperview()
//                })
//            })
//        }
//    }
//}

//extension RPicker: UIPickerViewDataSource, UIPickerViewDelegate {
//    
//    //function for the number of columns in the picker
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    //function counting the array to give the number of rows in the picker
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return dataArray.count
//    }
//    
//    //function displaying the array rows in the picker as a string
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return dataArray[row]
//    }
//}
//
//class RToolBar: UIView {
//    
//    open var didSelectDone: (() -> Void)?
//    open var didCancelled: (() -> Void)?
//    
//    var toolBarTitleItem: ToolBarTitleItem?
//
//    private var hideCancelButton: Bool = false
//    
//    var title = "" {
//        didSet {
//            guard let toolBarTitleItem = toolBarTitleItem else {
//                return
//            }
//             
//            toolBarTitleItem.label.text = title
//        }
//    }
//    
//    override init(frame: CGRect) {
//        
//        super.init(frame: frame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func addToolBar(hideCancelButton: Bool = false) {
//        self.hideCancelButton = hideCancelButton
//        self.addSubview(toolbar)
//    }
//    
//    open var toolbar: UIToolbar {
//        
//        let frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 48)
//        let toolBar = ToolBar(frame: frame, target: self)
//        
//        if !hideCancelButton {
//            toolBar.appendButton(buttonItem: toolBar.buttonItem(systemItem: .cancel, selector: #selector(self.cancelAction)))
//        }
//        
//        //toolBar.appendButton(buttonItem: toolBar.buttonItem(systemItem: .camera, selector: #selector(self.doneAction)))
//        toolBar.appendButton(buttonItem: toolBar.flexibleSpace)
//        
//        let toolBarTitleItem = toolBar.titleItem(text: "", font: UIFont(name: "HelveticaNeue-Medium", size: 15.0)!, color: UIColor.black)
//        self.toolBarTitleItem = toolBarTitleItem as? ToolBarTitleItem
//        toolBar.appendButton(buttonItem: toolBarTitleItem)
//        toolBar.appendButton(buttonItem: toolBar.flexibleSpace)
//        toolBar.appendButton(buttonItem: toolBar.buttonItem(systemItem: .done, selector: #selector(self.doneAction)))
//        
//        return toolBar
//    }
//    
//    @objc func doneAction() {
//        didSelectDone?()
//    }
//    
//    @objc func cancelAction() {
//        
//        if !hideCancelButton {
//            didCancelled?()
//        }
//    }
//}
//
//class ToolBar: UIToolbar {
//    
//    let target: Any?
//    
//    init(bottomBarWithHeight: CGFloat, target: Any?) {
//        self.target = target
//        
//        var bounds =  UIScreen.main.bounds
//        bounds.origin.y = bounds.height - bottomBarWithHeight
//        bounds.size.height = bottomBarWithHeight
//        
//        super.init(frame: bounds)
//    }
//    
//    init(frame: CGRect, target: Any?) {
//        self.target = target
//        super.init(frame: frame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func buttonItem(systemItem: UIBarButtonItem.SystemItem, selector: Selector?) -> UIBarButtonItem {
//        
//        return UIBarButtonItem(barButtonSystemItem: systemItem, target: target, action: selector)
//    }
//    
//    var flexibleSpace: UIBarButtonItem {
//        return buttonItem(systemItem: UIBarButtonItem.SystemItem.flexibleSpace, selector:nil)
//    }
//    
//    func titleItem (text: String, font: UIFont, color: UIColor) -> UIBarButtonItem {
//        return ToolBarTitleItem(text: text, font: font, color: color)
//    }
//    
//    func appendButton(buttonItem: UIBarButtonItem) {
//        if items == nil {
//            items = [UIBarButtonItem]()
//        }
//        
//        buttonItem.setTitleTextAttributes([
//            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 15.0)!,
//            NSAttributedString.Key.foregroundColor: UIColor(red: (49/255.0), green: (118/255.0), blue: 239, alpha: 1)],
//                                          for: .normal)
//        
//        items!.append(buttonItem)
//    }
//}
//
//class ToolBarTitleItem: UIBarButtonItem {
//    
//    var label: UILabel
//    
//    init(text: String, font: UIFont, color: UIColor) {
//        
//        var frame = UIScreen.main.bounds
//        frame.size.width = UIScreen.main.bounds.width - 112
//        
//        label =  UILabel(frame: frame)
//        label.text = text
//        label.sizeToFit()
//        label.font = font
//        label.textColor = color
//        label.textAlignment = .center
//        
//        super.init()
//        
//        customView = label
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}



