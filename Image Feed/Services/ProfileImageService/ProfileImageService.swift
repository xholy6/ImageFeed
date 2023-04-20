import Foundation

final class ProfileImageService {

    //MARK: - Singleton
    static let shared = ProfileImageService()
    private init() {}

    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    //MARK: - Private properties
    private let urlSession = URLSession.shared
    private let token = OAuth2TokenStorage.shared.token
    private var task: URLSessionTask?
    
    private(set) var avatarURL: String?

    func fetchProfile(_ userName: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()

        guard let token = token else { return }

        let request = profileImageRequest(with: userName, token: token)

        guard let request else { return }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let userResult):
                    let smallImageURLString = userResult.profileImage.large
                    self.avatarURL = smallImageURLString
                    completion(.success(smallImageURLString))
                    self.task = nil
                case .failure(let error):
                    completion(.failure(error))
                    self.task = nil
                }
            }
        }

        self.task = task
        task.resume()
    }

    private func profileImageRequest(with username: String, token: String) -> URLRequest? {
        var request = URLRequest.makeHTTPRequest(
            path: "/users"
            + "/\(username)",
            httpMethod: "GET",
            baseURL: AuthConfiguration.standart.apiBaseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
