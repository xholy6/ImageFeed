import Foundation

final class ImageListService {
    static let shared = ImageListService()
    
    private init() {}
    
    private (set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    
    static var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    func fetchPhotosNextPage () {
        assert(Thread.isMainThread)
        task?.cancel()
        
        var nextPage: Int
        
        if let lastLoadedPage = ImageListService.lastLoadedPage {
            nextPage = lastLoadedPage + 1
            ImageListService.lastLoadedPage = nextPage
        } else {
            nextPage = 1
            ImageListService.lastLoadedPage = nextPage
        }
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        let request = ImageListRequest(numberPage: nextPage, token: token)
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult],Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResult):
                    photoResult.forEach { result in
                        let photo = self.getPhoto(from: result)
                        self.photos.append(photo)
                    }
                    NotificationCenter.default.post(
                        name: ImageListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos" : self.photos])
                    self.task = nil
                case .failure(let error):
                    print(error)
                    self.task = nil
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    
    
    private func ImageListRequest(numberPage: Int, token: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/photos" + "?page=\(numberPage)",
            httpMethod: "GET",
            baseURL: Constants.apiBaseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func getPhoto(from result: PhotoResult) -> Photo {
        let imageSize = CGSize(width: CGFloat(result.width), height: CGFloat(result.height))
        let createdDate = DateFormatter().date(from: result.createdAt)
        let photo = Photo(id: result.id,
                          size: imageSize,
                          createdAt: createdDate,
                          welcomeDescription: result.description,
                          thumbImageURL: result.urls.thumb,
                          largeImageURL: result.urls.full,
                          isLiked: result.likedByUser)
        return photo
    }
    
}
