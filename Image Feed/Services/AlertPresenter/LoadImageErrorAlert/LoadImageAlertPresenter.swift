import UIKit

protocol LoadImageErrorAlertProtocol: AnyObject {
    func requestShowErrorLoadImageAlert(alertModel: AlertModel?)
}

protocol ErrorAlertPresenterDelegate: AnyObject {
    func showAlert(alertController: UIAlertController?)
}

final class LoadImageErrorAlertPresenter {
    private weak var delegate: ErrorAlertPresenterDelegate?
    
    init(delegate: ErrorAlertPresenterDelegate) {
        self.delegate = delegate
    }
}

extension LoadImageErrorAlertPresenter: LoadImageErrorAlertProtocol {
    func requestShowErrorLoadImageAlert(alertModel: AlertModel?) {
        let vc = UIAlertController(title: alertModel?.title, message: alertModel?.message, preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel?.buttonText, style: .default, handler: alertModel?.completion)
        let cancelAction = UIAlertAction(title: "Не надо", style: .default)
        vc.addAction(action)
        vc.addAction(cancelAction)
        delegate?.showAlert(alertController: vc)
    }
}
