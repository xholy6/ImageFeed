import UIKit

protocol ImageListPresenterProtocol: AnyObject {
    var view: ImageListViewControllerProtocol? { get set }
    func viewDidLoad()
}

final class ImageListPresenter: NSObject {
    //MARK: - Public properties
    weak var view: ImageListViewControllerProtocol?
    
    //MARK: - Private properties
    private var photos: [Photo] = []
    private let imageListService = ImageListService.shared
    private var imageListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

//MARK: ImageListPresenterProtocol
extension ImageListPresenter: ImageListPresenterProtocol {
    
    //MARK: - Public methods
    func viewDidLoad() {
        imageListService.fetchPhotosNextPage()
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImageListService.didChangeNotification,
                         object: nil,
                         queue: .main,
                         using: { [weak self] _ in
                guard let self = self else { return }
                self.requestUpdateTableView()
            })
    }
    
    //MARK: - Private methods
    private func requestUpdateTableView() {
        let oldPhotosCount = photos.count
        let newPhotosCount = imageListService.photos.count
        photos = imageListService.photos
        view?.updateTableView(oldPhotosCount: oldPhotosCount, newPhotosCount: newPhotosCount)
    }
    
    private func getSingleImageViewController(with photo: Photo) -> UIViewController? {
        let viewController = SingleImageViewController()
        viewController.imageURL = photo.largeImageURL
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }
    
    private func cellConfig(with photo: Photo) -> (dateString: String, imageURLString: String, isLikeImageString: String) {
        var dateString: String
        
        if let date = photo.createdAt {
            dateString = dateFormatter.string(from: date)
        } else {
            dateString = ""
        }
        
        let image = photo.thumbImageURL
        let isLikedImage: String = photo.isLiked ? "ActiveLike" : "NoActiveLike"
        
        return (dateString, image, isLikedImage)
    }
}

//MARK: UITableViewDelegate
extension ImageListPresenter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let viewController = getSingleImageViewController(with: photo)
        view?.presentSingleImageViewController(vc: viewController)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count-1 {
            imageListService.fetchPhotosNextPage()
        }
    }
}

//MARK: UITableViewDataSource
extension ImageListPresenter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let imagesListCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else { return UITableViewCell() }
        
        
        let photo = photos[indexPath.row]
        let cellConfig = cellConfig(with: photo)
        imagesListCell.delegate = self
        imagesListCell.configCell(date: cellConfig.dateString,
                                  imageURL: cellConfig.imageURLString,
                                  likedImage: cellConfig.isLikeImageString,
                                  numberRow: indexPath.row)
        imagesListCell.selectionStyle = .none
        return imagesListCell
    }
}

//MARK: ImagesListCellDelegate
extension ImageListPresenter: ImagesListCellDelegate {
    
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = view?.getCellIndexPath(cell: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imageListService.changeLike(idPhoto: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
            case .failure(let failure):
                print(failure)
                
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func reloadCellHeight(numberRow: Int) {
        let indexPath = IndexPath(item: numberRow, section: 0)
        view?.updateCellHeght(indexPath: indexPath)
    }
}
