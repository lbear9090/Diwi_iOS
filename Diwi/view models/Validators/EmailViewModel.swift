
import Foundation
import RxSwift
import RxCocoa

struct EmailViewModel : ValidationViewModel{
    
    var errorMessage: String = "Please enter a valid Email"
    
    var data = BehaviorRelay<String>(value: "")
    var errorValue = BehaviorRelay<String>(value: "")
    
    func validateCredentials() -> Bool {
        
        guard validatePattern(text: data.value) else {
            errorValue.accept(errorMessage)
            return false
        }
        
        errorValue.accept("")
        return true
    }
    
    func validatePattern(text : String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
}
