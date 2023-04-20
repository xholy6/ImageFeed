import UIKit
import Kingfisher

final class ProfileHelper {

    var imageView: UIImageView?

    init(imageView: UIImageView? = UIImageView()) {
        self.imageView = imageView
    }

}

extension ProfileHelper: ProfileHelperProtocol {
    func loadImage(url: URL?, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard
            let imageView,
            let url = url else { return }

        imageView.kf.setImage(with: url, placeholder: nil, options: nil) { result in
            switch result {
            case .success(let value):
                completion(.success(value.image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
