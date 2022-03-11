import Foundation
import RxSwift
import RxCocoa

struct UsernameViewModel: ValidationViewModel {
    var errorMessage: String = "Username cannot be empty"
    
    var data = BehaviorRelay<String>(value: "")
    var errorValue = BehaviorRelay<String>(value: "")
    
    func validateCredentials() -> Bool {
        
        guard validateExists(text: data.value) else {
            errorValue.accept(errorMessage)
            return false;
        }
        
        errorValue.accept("")
        return true
    }
    
    func validateExists(text: String) -> Bool{
        return !text.isEmpty
    }
}
