import Foundation
import UIKit

class Validators {
    
    static func email(email: String) -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
    static func password(password: String) -> Bool {
        // at least one uppercase, one number, one lowercase, min 8 chars,
        // chnage regex to your needs
        let regex = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}"
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return passwordTest.evaluate(with: password)
    }
    
    static func passwordMatch(password: String, passwordConfirm: String) -> Bool {
        return password == passwordConfirm
    }
    
    static func minLength(length: Int, text: String) -> Bool {
        return text.count >= length
    }
    
    // pass in text field and error label for field
    static func validationError(textField: UITextField, errorMessage: UILabel) {
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.red.cgColor
        errorMessage.textColor = UIColor.red
    }
    
    // pass in text field and error label for field
    static func validationSuccess(textField: UITextField, errorMessage: UILabel) {
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        errorMessage.textColor = UIColor(red:0.26, green:0.82, blue:0.69, alpha:1.0)
    }
}

