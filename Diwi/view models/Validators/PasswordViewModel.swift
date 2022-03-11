
import Foundation
import RxSwift
import RxCocoa

struct PasswordViewModel: ValidationViewModel {
    var errorMessage: String = "Password must be at leat 8 characters long"
    
    var data = BehaviorRelay<String>(value: "")
    var errorValue = BehaviorRelay<String>(value: "")
    
    func validateCredentials() -> Bool {
        
        guard validateLength(text: data.value, size: (8,25)) else {
            errorValue.accept(errorMessage)
            return false;
        }
        
        errorValue.accept("")
        return true
    }
    
    func validateLength(text: String, size: (min: Int, max: Int)) -> Bool{
        return (size.min...size.max).contains(text.count)
    }
}
