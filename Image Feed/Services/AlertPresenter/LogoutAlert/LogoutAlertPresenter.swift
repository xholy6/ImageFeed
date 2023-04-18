import UIKit

protocol LogoutAlertPresenterProtocol: AnyObject {
    func requestShowLogoutAlert(alertModel: AlertModel?)
}

protocol LogoutAlertPresenterDelegate: AnyObject {
    func showLogoutAlert(alertController: UIAlertController?)
}

final class LogoutAlertPresenter {
    private weak var delegate: LogoutAlertPresenterDelegate?
    
    init(delegate: LogoutAlertPresenterDelegate) {
        self.delegate = delegate
    }
}

extension LogoutAlertPresenter: LogoutAlertPresenterProtocol {
    func requestShowLogoutAlert(alertModel: AlertModel?) {
        let vc = UIAlertController(title: alertModel?.title, message: alertModel?.message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: alertModel?.buttonText, style: .default, handler: alertModel?.completion)
        let noAction = UIAlertAction(title: "Нет", style: .default)
        vc.addAction(yesAction)
        vc.addAction(noAction)
        delegate?.showLogoutAlert(alertController: vc)
    }
}
