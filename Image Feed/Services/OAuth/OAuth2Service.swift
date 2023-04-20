import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    //MARK: - Private properties
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    
    private var lastCode: String?
    
    //MARK: - Public methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void ) {
        assert(Thread.isMainThread)
        
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = authTokenRequest(code: code)
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    OAuth2TokenStorage.shared.token = authToken
                    completion(.success(authToken))
                    self.task = nil
                case .failure(let error):
                    self.lastCode = nil
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
}

extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AuthConfiguration.standart.accessKey)"
            + "&&client_secret=\(AuthConfiguration.standart.secretKey)"
            + "&&redirect_uri=\(AuthConfiguration.standart.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST")
    }
}



