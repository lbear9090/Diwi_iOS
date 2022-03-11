import UIKit
import Foundation

extension UserDefaults {
    private enum Keys {
        static let DidSeedPersistentStore = "didSeedPersistentStore"
    }
    
    enum GlobalKeys {
        static let FriendsListKey = "FriendsListKey"
    }
    
    class func setDidSeedPersistentStore(_ didSeedPersistentStore: Bool) {
        UserDefaults.standard.set(didSeedPersistentStore, forKey: Keys.DidSeedPersistentStore)
    }
    
    class var didSeedPersistentStore: Bool {
        return UserDefaults.standard.bool(forKey: Keys.DidSeedPersistentStore)
    }
    
    class func didDestroyPersistentStore() {
        UserDefaults.standard.removeObject(forKey: Keys.DidSeedPersistentStore)
    }
    
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}
