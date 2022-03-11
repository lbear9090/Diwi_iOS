
import Foundation
import RxSwift

protocol LoginService {
    func login(with user: User) -> Observable<LoginResponse>
}
