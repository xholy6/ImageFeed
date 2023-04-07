import UIKit

protocol ErrorAuthAlertPresenterProtocol: AnyObject {
    func requestShowResultAlert(alertModel: AlertModel?)
}

final class ErrorAuthAlertPresenter {
    private weak var delegate: ErrorAlertPresenterDelegate?
    
    init(delegate: ErrorAlertPresenterDelegate) {
        self.delegate = delegate
    }
}

extension ErrorAuthAlertPresenter: ErrorAuthAlertPresenterProtocol {
    func requestShowResultAlert(alertModel: AlertModel?) {
        let vc = UIAlertController(title: alertModel?.title, message: alertModel?.message, preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel?.buttonText, style: .default, handler: alertModel?.completion)
        vc.addAction(action)
        delegate?.showAlert(alertController: vc)
    }
    
}
