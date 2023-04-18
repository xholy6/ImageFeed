import UIKit

struct Constants {
    static let accessKey = "SRYWb3dIxatktXTrYY8DQfuxTiO_KQP0rplncX8Adys"
    static let secretKey = "apZcSH2-MDtUQdeDNpLX6rCCo8H73yeuVKi7IMN3Ndw"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL =  URL(string: "https://unsplash.com")!
    static let apiBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let responseType = "code"
    static let urlComponentsPath = "/oauth/authorize/native"
}
