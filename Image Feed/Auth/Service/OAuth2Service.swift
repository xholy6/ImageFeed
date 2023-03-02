import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    //MARK: - Private properties
    private let urlSession = URLSession.shared
    
    
    //MARK: - Public methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void ) {
        let request = authTokenRequest(code: code)
        
        let task = object(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    OAuth2TokenStorage.shared.token = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

extension OAuth2Service {
    //MARK: - Private methods
    private func object( for request: URLRequest,completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
    
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST")
    }
}


