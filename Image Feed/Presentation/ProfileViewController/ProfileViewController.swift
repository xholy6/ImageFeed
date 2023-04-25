import UIKit
import WebKit

protocol ProfileViewControllerProtocol: AnyObject {
    func showAlertGetAvatarError(alertModel: AlertModel)
    func logoutProfile(alertModel: AlertModel)
}
final class ProfileViewController: UIViewController {
    //MARK: - Private properties
    private var profileScreenView: ProfileScreenView!
    private var errorAlertPresenter: ErrorAuthAlertPresenterProtocol?
    private var logoutAlertPresenter: LogoutAlertPresenterProtocol?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileScreenView = ProfileScreenView(frame: .zero, viewController: self)
        errorAlertPresenter =  ErrorAuthAlertPresenter(delegate: self)
        logoutAlertPresenter = LogoutAlertPresenter(delegate: self)
        setupView()
        
    }
    
    //MARK: - Private methods
    private func setupView() {
        view.backgroundColor = .ypBlack
        setScreenViewOnViewController(view: profileScreenView)
    }
}

extension ProfileViewController: ProfileViewControllerProtocol {
    
    func logoutProfile(alertModel: AlertModel) {
        logoutAlertPresenter?.requestShowLogoutAlert(alertModel: alertModel)
    }
    
    func showAlertGetAvatarError(alertModel: AlertModel) {
        errorAlertPresenter?.requestShowResultAlert(alertModel: alertModel)
    }
}

extension ProfileViewController: ErrorAlertPresenterDelegate {
    func showAlert(alertController: UIAlertController?) {
        guard let alertController = alertController else { return }
        present(alertController, animated: true)
    }
}

extension ProfileViewController: LogoutAlertPresenterDelegate {
    func showLogoutAlert(alertController: UIAlertController?) {
        guard let alertController = alertController else { return }
        present(alertController, animated: true)
    }
}
