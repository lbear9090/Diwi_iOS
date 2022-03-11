import Foundation
import KeychainSwift

class KeychainService {

    static let shared = KeychainService()

    let keychain = KeychainSwift()
    
    func setUserJWT(jwt: String) {
        keychain.set(jwt, forKey: "jwt")
    }
    
    func getUserJWT() -> String? {
        return keychain.get("jwt")
    }
    
    func setUserEmail(email: String) {
        keychain.set(email, forKey: "email")
    }
    
    func setUsername(username: String) {
        keychain.set(username, forKey: "username")
    }
    
    func setUserId(id: String) {
        keychain.set(id, forKey: "userId")
    }
    
    func setProfileId(id: String) {
        keychain.set(id, forKey: "profileId")
    }
    
    func clearAll() {
        keychain.clear()
    }
    
    func getUserEmail() -> String? {
        return keychain.get("email")
    }
    
    func getUserPassword() -> String? {
        return keychain.get("password")
    }
    
    func getUsername() -> String? {
        return keychain.get("username")
    }
    
    func getUserId() -> String? {
        return keychain.get("userId")
    }
    
    func getProfileId() -> String? {
        return keychain.get("profileId")
    }
    
    func setUserPassword(password: String) {
        keychain.set(password, forKey: "password")
    }
    
    func setUserDeviceToken(token: String) {
        keychain.set(token, forKey: "deviceToken")
    }
    
    func getUserDeviceToken() -> String? {
        return keychain.get("deviceToken")
    }
    
    func setRememberTrue() {
        keychain.set(true, forKey: "remember")
    }
    
    func isRemember() -> Bool {
        if let remember =  keychain.getBool("remember") {
            return remember
        }
        
        return false
    }
    
    func clearValues() {
        keychain.clear()
    }
}

extension KeychainService: UserInfoService {}

