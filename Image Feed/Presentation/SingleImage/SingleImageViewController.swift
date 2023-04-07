import UIKit
import Kingfisher

protocol SingleImageViewControllerProtocol: AnyObject {
    func dismissViewController()
    func sharingImage(_ image: UIImage?)
    func showAlertLoadImageError()
}

final class SingleImageViewController: UIViewController {
    
    // MARK: - Private properties
    private var sharingPresenter: SharingPresenterProtocol!
    private var singleImageScreen: SingleImageViewControllerScreen!
    private var alertPresenter: LoadImageErrorAlertProtocol?
    
    //MARK: - Public properties
    var imageURL: String?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        singleImageScreen = SingleImageViewControllerScreen(viewController: self)
        sharingPresenter = SharingPresenter(delegate: self)
        alertPresenter = LoadImageErrorAlertPresenter(delegate: self)
        setScreenViewOnViewController(view: singleImageScreen)
        singleImageScreen.fetchImage(imageURL)
    }
    // MARK: - Private func
    private func showImageErrorAlert() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Попробовать еще раз?",
            buttonText: "Повторить", completion: { [weak self]_ in
                guard let self = self else { return }
                self.singleImageScreen.fetchImage(self.imageURL)
            })
        
        alertPresenter?.requestShowErrorLoadImageAlert(alertModel: alertModel)
    }
    
    deinit {
        print("deinit")
    }
}
// MARK: - SharingPresenterDelegate
extension SingleImageViewController: SharingPresenterDelegate {
    func shareImage(viewController: UIActivityViewController?) {
        guard let viewController else { return }
        present(viewController, animated: true)
    }
}

// MARK: - SingleImageViewControllerProtocol
extension SingleImageViewController: SingleImageViewControllerProtocol {
    func showAlertLoadImageError() {
        showImageErrorAlert()
    }
    
    func dismissViewController() {
        dismiss(animated: true)
    }
    
    func sharingImage(_ image: UIImage?) {
        sharingPresenter.requestSharingImage(for: image)
    }
}

// MARK: - ErrorAlertPresenterDelegate
extension SingleImageViewController: ErrorAlertPresenterDelegate {
    func showAlert(alertController: UIAlertController?) {
        guard let alertController = alertController else { return }
        present(alertController, animated: true)
    }
}
