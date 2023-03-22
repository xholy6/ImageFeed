import Foundation

final class ProfileService {
    
    //MARK: - Singleton
    static let shared = ProfileService()
    private init() {}
    
    //MARK: - Private properties
    private let urlSession = URLSession.shared
    
    //MARK: - ProfileService
    private enum ProfileServiceError: Error {
        case getProfileDetailError
    }

    private var task: URLSessionTask?
    
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = profileRequest(with: token)
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profileResult):
                    guard let profile = self.getProfile(from: profileResult) else {
                        completion(.failure(ProfileServiceError.getProfileDetailError))
                        return
                    }
                    self.profile = profile
                    completion(.success(profile))
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
    
    private func profileRequest(with code: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURL: Constants.apiBaseURL)
        request.setValue("Bearer \(code)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func getProfile(from profile: ProfileResult) -> Profile? {
        Profile(username: profile.username, firstName: profile.firstName, lastName: profile.lastName, bio: profile.bio ?? "")
    }
}
