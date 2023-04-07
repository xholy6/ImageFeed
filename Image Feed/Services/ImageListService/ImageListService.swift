import Foundation

final class ImageListService {
    static let shared = ImageListService()
    
    private init() {}
    
    private (set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    
    private enum HTTPMethods: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    func fetchPhotosNextPage () {
        assert(Thread.isMainThread)
        task?.cancel()
        
        var nextPage: Int
        
        if let lastLoadedPage = lastLoadedPage {
            nextPage = lastLoadedPage + 1
            self.lastLoadedPage = nextPage
        } else {
            nextPage = 1
            self.lastLoadedPage = nextPage
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
            httpMethod: HTTPMethods.get.rawValue,
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
    
    func changeLike(idPhoto: String,
                    isLike: Bool,
                    _ completion: @escaping (Result<Void, Error>)-> Void ) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let token = OAuth2TokenStorage.shared.token else { return }
        
        let httpMethod = isLike ? HTTPMethods.post.rawValue : HTTPMethods.delete.rawValue
        let request = likeRequest(id: idPhoto, HTTPMethod: httpMethod, token: token)
        
        let task = urlSession.dataTask(with: request) { [weak self] _, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
                return
            }
            guard
                let response = response,
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode == 201 || statusCode == 200,
                let self = self else { return }
            
            self.changePhoto(photoId: idPhoto)
            completion(.success(Void()))
        }
        
        self.task = task
        task.resume()
    }
    
    private func likeRequest(id: String, HTTPMethod: String, token: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/photos" + "/\(id)/like",
            httpMethod: HTTPMethod,
            baseURL: Constants.apiBaseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func changePhoto(photoId: String) {
        if let index = self.photos.firstIndex(where: { $0.id == photoId}) {
            let photo = self.photos[index]
            let newPhoto = Photo(id: photo.id,
                                 size: photo.size,
                                 createdAt: photo.createdAt,
                                 welcomeDescription: photo.welcomeDescription,
                                 thumbImageURL: photo.thumbImageURL,
                                 largeImageURL: photo.largeImageURL,
                                 isLiked: !photo.isLiked)
            
            self.photos[index] = newPhoto
        }
    }
}
