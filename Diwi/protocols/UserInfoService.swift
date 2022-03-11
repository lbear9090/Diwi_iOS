import Foundation

protocol UserInfoService {
    func setUserJWT(jwt: String) -> Void
    func setUserEmail(email: String) -> Void
    func setUsername(username: String) -> Void
    func setUserId(id: String) -> Void
    func setProfileId(id: String) -> Void
    func setUserPassword(password: String) -> Void
    func getUserDeviceToken() -> String?
    func getUserPassword() -> String?
    func getUserEmail() -> String?
    func getUsername() -> String?
    func getUserId() -> String?
}
