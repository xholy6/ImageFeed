import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    
    func configCell(date: String, imageURL: String, likedImage: String, numberRow: Int) {
        dateLabel.text = date
        likeButton.setImage(UIImage(named: likedImage), for: .normal)
        downloadImage(at: imageURL, numberRow: numberRow)
    }
    
    override func prepareForReuse() {
        imageCell.kf.cancelDownloadTask()
        dateLabel.text = nil
        likeButton.imageView?.image = nil
    }
    
    
    
    private func downloadImage(at url: String, numberRow: Int) {
        guard let url = URL(string: url) else { return }
        imageCell.kf.indicatorType = .activity
        imageCell.kf.setImage(with: url,
                              placeholder: UIImage(named: "Stub"),
                              options: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.imageCell.image = value.image
            case .failure(_):
                self.imageCell.image = UIImage(named: "Stub")
            }
        }
    }
}
