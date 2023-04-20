import UIKit
import ProgressHUD
import Kingfisher

final class SingleImageViewControllerScreen: UIView {
    
    weak var viewController: SingleImageViewControllerProtocol?
    
    private var needShowErrorAlert = true
    
    //MARK: - UI Objects
    
    private lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .ypBlack
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var backButton: UIButton = {
        let button: UIButton = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Backward"), for: .normal)
        button.accessibilityIdentifier = "Nav back button"
        button.addTarget(self, action: #selector(didBackButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var sharingButton: UIButton = {
        let button: UIButton = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Sharing"), for: .normal)
        button.addTarget(self, action: #selector(sharingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .ypBlack
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubViews()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewController: SingleImageViewControllerProtocol) {
        self.init()
        self.viewController = viewController
    }
    
    //MARK: - Public methods
    func fetchImage(_ imageURL: String?) {
        guard
            let urlString = imageURL,
            let url = URL(string: urlString) else {
            self.viewController?.showAlertLoadImageError()
            return
        }
        
        ProgressHUD.show()
        imageView.kf.setImage(with: url, options: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.imageView.image = value.image
                self.rescaleAndCenterImageInScrollView(image: value.image)
                self.sharingButton.isEnabled = true
            case .failure(_):
                if self.needShowErrorAlert {
                    self.viewController?.showAlertLoadImageError()
                    self.needShowErrorAlert = true
                }
            }
            ProgressHUD.dismiss()
        }
    }
    //MARK: - Private methods
    
    private func addSubViews() {
        addSubview(scrollView)
        addSubview(backButton)
        addSubview(sharingButton)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        scrollView.addSubview(imageView)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 54),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            
            sharingButton.heightAnchor.constraint(equalToConstant: 50),
            sharingButton.widthAnchor.constraint(equalToConstant: 50),
            sharingButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            sharingButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -71)
        ])
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    @objc private func didBackButtonTapped() {
        needShowErrorAlert = false
        imageView.kf.cancelDownloadTask()
        viewController?.dismissViewController()
        
    }
    
    @objc private func sharingButtonTapped() {
        viewController?.sharingImage(imageView.image)
    }
}

//MARK: - UIScrollViewDelegate
extension SingleImageViewControllerScreen: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
