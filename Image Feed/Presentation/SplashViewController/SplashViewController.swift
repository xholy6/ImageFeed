import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private var splashScreenView = SplashViewControllerScreen()
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var alertPresenter: ErrorAuthAlertPresenter?
    
    private let authenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let tabBarIdentifier = "TabBarViewController"
    private let authViewControllerIdentifier = "AuthViewController"
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = ErrorAuthAlertPresenter(delegate: self)
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkToken()
    }
    
    //MARK: - Override method
    private func setupView() {
        view.backgroundColor = .ypBlack
        setScreenViewOnViewController(view: splashScreenView)
    }
    
    //MARK: - Private methods
    private func getAuthViewController() -> UINavigationController {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
    private func presentAuthViewController() {
        let viewController = getAuthViewController()
        present(viewController, animated: true)
    }
    
    
    private func switchToTabBarController() {
        guard
            let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration")}
        let tabBarVC = TabBarController()
        window.rootViewController = tabBarVC
    }

    private func checkToken() {
        if let token = OAuth2TokenStorage.shared.token {
            UIBlockingProgressHUD.show()
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
}

// MARK: AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        fetchToken(code)
    }
    
    private func fetchToken(_ code: String) {
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            guard let self = self  else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.presentAuthViewController()
                self.showAlert()
                
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let profile):
                self.fetchProfileImageURL(username: profile.username)
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print(error)
                self.showAlert()
                self.presentAuthViewController()
            }
        }
    }
    
    private func fetchProfileImageURL(username: String) {
        profileImageService.fetchProfile(username) { [weak self] result in
            switch result {
            case .success(let profileImageURL):
                NotificationCenter.default
                    .post(name: ProfileImageService.didChangeNotification,
                          object: self,
                          userInfo: ["URL" : profileImageURL])
            case .failure(_):
                self?.showAlert()
            }
        }
    }
    private func showAlert() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            buttonText: "Ok", completion: { [weak self] _ in
                guard let self = self else { return }
                self.checkToken()
            })
        
        alertPresenter?.requestShowResultAlert(alertModel: alertModel)
    }
}
extension SplashViewController: ErrorAlertPresenterDelegate {
    func showAlert(alertController: UIAlertController?) {
        guard let alertController = alertController else { return }
        present(alertController, animated: true, completion: nil)
    }
}
