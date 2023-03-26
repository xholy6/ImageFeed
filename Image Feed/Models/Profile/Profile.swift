import Foundation

struct Profile {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String

    var name: String {
         "\(firstName) \(lastName)"
    }

    var loginName: String {
        "@\(username)"
    }
}
