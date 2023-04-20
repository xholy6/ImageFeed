import UIKit

protocol ProfileHelperProtocol {
    var imageView: UIImageView? { get set }
    func loadImage(url: URL?, completion: @escaping (Result<UIImage, Error>) -> Void)
}
