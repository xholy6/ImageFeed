import UIKit

protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListPresenterProtocol? { get set }
    func updateTableView(oldPhotosCount: Int, newPhotosCount: Int)
    func presentSingleImageViewController(vc: UIViewController?)
    func updateCellHeght(indexPath: IndexPath)
    func getCellIndexPath(cell: UITableViewCell) -> IndexPath?
}

final class ImagesListViewController: UIViewController {
    
    var presenter: ImageListPresenterProtocol?
    
    // MARK: - @IBOutlet
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.accessibilityIdentifier = "Image list"
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter = ImageListPresenter()
        presenter?.view = self
        tableView.dataSource = presenter as? ImageListPresenter
        tableView.delegate = presenter as? ImageListPresenter
        presenter?.viewDidLoad()
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

//MARK: - ImageListViewControllerProtocol
extension ImagesListViewController: ImageListViewControllerProtocol {
    func getCellIndexPath(cell: UITableViewCell) -> IndexPath? {
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        return indexPath
    }
    
    func updateTableView(oldPhotosCount: Int, newPhotosCount: Int) {
        if oldPhotosCount != newPhotosCount {
            tableView.performBatchUpdates {
                let indexPath = (oldPhotosCount..<newPhotosCount).map { IndexPath(row: $0, section: 0)}
                tableView.insertRows(at: indexPath, with: .automatic)
            }
        }
    }
    
    func presentSingleImageViewController(vc: UIViewController?) {
        guard let vc = vc else { return }
        present(vc, animated: true)
    }
    
    
    func updateCellHeght(indexPath: IndexPath) {
        tableView.performBatchUpdates {
            tableView.reloadRows(at: [indexPath], with: .automatic )
        }
    }
}
