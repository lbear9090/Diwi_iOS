//
//  TextfieldWithIconTableViewCell.swift
//  Diwi
//
//  Created by Shane Work on 12/1/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import IQKeyboardManager
protocol TextFieldCellDelegate: NSObjectProtocol {
    func updateDate(_ text: String)
    func updateLocation(_ text: String)
}

class TextfieldWithIconTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    static let identifier = "TextfieldWithIconTableViewCell"
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    let datePicker = UIDatePicker()
    var pickerType = false
    var isEdit: Bool = true

    weak var delegate: TextFieldCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.autocapitalizationType = .words
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    func configureCell(_ img: UIImage, _ delegate: TextFieldCellDelegate,_ newLook: NewLook, _ openPicker: Bool = false) {
        icon.image = img
        pickerType = openPicker
        self.delegate = delegate
        if openPicker {
            self.textField.placeholder = "When you wore it (MMMM dd, yyyy)"
            self.textField.text = newLook.datesWorn.last ?? ""
            showDatePicker(textField)
        } else {
            self.textField.placeholder = "Where you wore it"
            self.textField.text = newLook.location
            textField.keyboardType = .default
        }
        self.textField.isUserInteractionEnabled = isEdit
        containerView.layer.borderColor = UIColor.Diwi.azure.cgColor
        containerView.layer.borderWidth = isEdit ? 1 : 0
        containerView.layer.cornerRadius = 5
    }
 
    func showDatePicker(_ textFiled:UITextField){
         datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        } else {
            // Fallback on earlier versions
        }
        
//        datePicker.maximumDate = Date().dateByAddingDays(-1)
        datePicker.date = self.stringToDate(textFiled.text ?? "","MMMM dd, yyyy") ?? Date()
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TextfieldWithIconTableViewCell.donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TextfieldWithIconTableViewCell.cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        textFiled.inputAccessoryView = toolbar
        textFiled.inputView = datePicker
        textFiled.text = (self.stringToDate(textFiled.text ?? "","MMMM dd, yyyy") ?? Date()).toString("MMMM dd, yyyy")
        delegate?.updateDate(textField.text ?? "")
    }
    
    //MARK:- Action
    @objc  func donedatePicker(){
        //For date formate
        textField.text = datePicker.date.onlyDateString("MMMM dd, yyyy")
        delegate?.updateDate(textField.text ?? "")
        //dismiss date picker dialog
        self.endEditing(true)
    }
    
    @objc  func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        self.endEditing(true)
    }
    
    func stringToDate(_ str: String, _ format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        var date: Date? = dateFormatter.date(from: str)
        if date == nil
        {
            dateFormatter.dateFormat = format
            date = dateFormatter.date(from: str)
        }
        let todaysDate = dateFormatter.string(from: date ?? Date())
        let updatedDate: Date? = dateFormatter.date(from: todaysDate) as Date?
        return updatedDate
    }
}

extension TextfieldWithIconTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !pickerType {
        delegate?.updateLocation(textField.text ?? "")
        }
//        IQKeyboardManager.shared().isEnableAutoToolbar = true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if pickerType {
//            IQKeyboardManager.shared().isEnableAutoToolbar = false
        }
        return true
    }
}
