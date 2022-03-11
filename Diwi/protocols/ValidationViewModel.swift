
import Foundation
import RxSwift
import RxCocoa

protocol ValidationViewModel {
    var errorMessage: String { get }
    
    var data: BehaviorRelay<String> { get set }
    var errorValue: BehaviorRelay<String> { get set }
    
    func validateCredentials() -> Bool
}
