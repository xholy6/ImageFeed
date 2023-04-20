import Foundation

final class AuthHelper: AuthHelperProtocol {
    
    private let configuration: AuthConfiguration
    
    private struct AuthHelperConstants {
        static let responseType = "code"
    }
    
    init(configuration: AuthConfiguration = .standart) {
        self.configuration = configuration
    }
    
    var authRequest: URLRequest? {
        guard let url = authURL() else { return nil }
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == AuthHelperConstants.responseType})
        {
            return codeItem.value
        }
        return nil
    }
    
    func authURL() -> URL? {
        var urlComponents = URLComponents(string: configuration.unsplashAuthorizeURLString)!

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: AuthHelperConstants.responseType),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        guard let url = urlComponents.url else { return nil }
        return url
    }
}
