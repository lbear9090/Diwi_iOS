import Foundation
import RxSwift

protocol ForgotPasswordService {
    func forgotPassword(with user: User) -> Observable<User>
}
