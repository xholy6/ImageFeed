import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    //MARK: Private enum
    private enum Keys: String {
        case token = "Auth token"
    }
    
    //MARK: Private properties
    private let keyChainWrapper = KeychainWrapper.standard
    
    //MARK: Public properties
    var token: String? {
        get { keyChainWrapper.string(forKey: Keys.token.rawValue)}
        set {
            guard let newValue else { return }
            let isSuccess = keyChainWrapper.set(newValue, forKey: Keys.token.rawValue)
            guard isSuccess else {
                assertionFailure("Cannot set token")
                return
            }
        }
    }
    
    func removeToken() {
        keyChainWrapper.removeObject(forKey: Keys.token.rawValue)
    }
}
