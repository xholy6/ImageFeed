import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
    func reloadCellHeight(numberRow: Int)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    private lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .ypBlack
        contentView.addSubview(cellImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(likeButton)
        
        NSLayoutConstraint.activate([
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -4),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 4),
            
            dateLabel.leftAnchor.constraint(equalTo: cellImageView.leftAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -4),
            
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.rightAnchor.constraint(equalTo: cellImageView.rightAnchor, constant: -10),
            likeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor, constant: 12)
        ])
    }
    
    func configCell(date: String, imageURL: String, likedImage: String, numberRow: Int) {
        dateLabel.text = date
        likeButton.setImage(UIImage(named: likedImage), for: .normal)
        downloadImage(at: imageURL, numberRow: numberRow)
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage: String = isLiked ? "ActiveLike" : "NoActiveLike"
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.likeButton.setImage(UIImage(named: likeImage), for: .normal)
        }
    }
    
    override func prepareForReuse() {
        cellImageView.kf.cancelDownloadTask()
        dateLabel.text = nil
        likeButton.imageView?.image = nil
    }
    
    
    
    private func downloadImage(at url: String, numberRow: Int) {
        guard let url = URL(string: url) else { return }
        cellImageView.kf.indicatorType = .activity
        cellImageView.kf.setImage(with: url,
                                  placeholder: UIImage(named: "Stub"),
                                  options: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.cellImageView.image = value.image
                self.delegate?.reloadCellHeight(numberRow: numberRow)
            case .failure(_):
                self.cellImageView.image = UIImage(named: "Stub")
            }
        }
    }
    
    @objc private func likeButtonTapped() {
        delegate?.imagesListCellDidTapLike(self)
    }
}
