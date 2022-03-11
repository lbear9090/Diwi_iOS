import Foundation
import RxSwift
import RxCocoa

struct TermsViewModel {
    var errorMessage: String = "Must accept terms and conditions"
    
    var data = BehaviorRelay<Bool>(value: false)
    var errorValue = BehaviorRelay<String>(value: "")
    
    func validateCredentials() -> Bool {
        
        if (data.value) {
            errorValue.accept("")
        }
        else {
            errorValue.accept(errorMessage)
        }
        
        return data.value
    }
}
