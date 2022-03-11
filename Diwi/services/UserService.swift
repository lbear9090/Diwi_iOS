import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import RxSwift

class UserService: MainRequestService {
    
    func login(with user: User) -> Observable<LoginResponse> {
        return newRequestWithoutKeyPath(route: UserRouter.login(user))
    }
    
    func signUp(with user: User) -> Observable<User> {
        return newRequestWithKeyPath(route: UserRouter.signup(user),
                                     keypath: TextContent.KeyPaths.user)
    }
    
    func forgotPassword(with user: User) -> Observable<User> {
        return newRequestWithKeyPath(route: UserRouter.forgotPassword(user), keypath: TextContent.KeyPaths.passwordReset)
    }
    
    func acceptTerms(with terms: Terms) -> Observable<Terms> {
        return newRequestWithoutKeyPath(route: UserRouter.acceptTerms(terms))
    }
    
    func update(with user: User) -> Observable<User> {
        return newRequestWithoutKeyPath(route: UserRouter.update(user))
    }
}

extension UserService: LoginService,
                       SignupService,
                       ForgotPasswordService,
                       UpdateUserService {}

