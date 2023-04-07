import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - @IBOutlet
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
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
        setupView()
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
    
    private func setupView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
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
        
        imageListCell.delegate = self
        
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
        let photo = photos[indexPath.row]
        let singleImageViewController = SingleImageViewController()
        singleImageViewController.imageURL = photo.largeImageURL
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func reloadCellHeight(numberRow: Int) {
        let indexPath = IndexPath(item: numberRow, section: 0)

        tableView.performBatchUpdates {
            tableView.reloadRows(at: [indexPath], with: .automatic )
        }
    }
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imageListService.changeLike(idPhoto: photo.id, isLike: !photo.isLiked, {
            [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                self.photos = self.imageListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let failure):
                print(failure)
            }
        })
    }
}
