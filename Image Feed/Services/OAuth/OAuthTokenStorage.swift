import Foundation

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    //MARK: Private enum
    private enum Keys: String {
        case token
    }
    
    //MARK: Private properties
    private let userDefault = UserDefaults.standard
    
    //MARK: Public properties
    var token: String? {
        get { userDefault.string(forKey: Keys.token.rawValue)}
        set { userDefault.set(newValue, forKey: Keys.token.rawValue)}
    }
}
