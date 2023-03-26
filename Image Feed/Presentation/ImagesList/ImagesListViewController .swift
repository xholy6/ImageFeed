import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private properties
    private var photos: [Photo] = []
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImageListService.shared
    private var imageListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        imageListService.fetchPhotosNextPage()
        imageListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImageListService.didChangeNotification,
                         object: nil,
                         queue: .main,
                         using: { [weak self] _ in
                guard let self = self else { return }
                self.updateTableView()
            })
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let image = UIImage(named: "Stub")
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func updateTableView() {
        let oldPhotosCount = photos.count
        let newPhotosCount = imageListService.photos.count
        photos = imageListService.photos
        
        if oldPhotosCount != newPhotosCount {
            tableView.performBatchUpdates {
                let indexPath = (oldPhotosCount..<newPhotosCount).map { IndexPath(row: $0, section: 0)}
                tableView.insertRows(at: indexPath, with: .automatic)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        
        let photo = photos[indexPath.row]
        let date = dateFormatter.string(from: photo.createdAt ?? Date())
        let image = photo.thumbImageURL
        let isLikedImage: String = photo.isLiked ? "ActiveLike" : "NoActiveLike"
        imageListCell.configCell(date: date, imageURL: image, likedImage: isLikedImage, numberRow: indexPath.row)
        imageListCell.selectionStyle = .none
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imageListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let photoSize = photo.size
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photoSize.height * scale - imageInsets.top - imageInsets.bottom
        return cellHeight
    }
}
