import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private var splashScreenView = SplashViewControllerScreen()
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var alertPresenter: ErrorAlertPresenterProtocol?
    
    private let authenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let tabBarIdentifier = "TabBarViewController"
    private let authViewControllerIdentifier = "AuthViewController"
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = ErrorAlertPresenter(delegate: self)
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkToken()
    }
    
    //MARK: - Override method
    private func setupView() {
        view.backgroundColor = .ypBlack
        addView()
    }
    
    private func addView() {
        view.addSubview(splashScreenView)
        NSLayoutConstraint.activate([
            splashScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            splashScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splashScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            splashScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //MARK: - Private methods
    private func presentAuthViewController() {
        guard let authViewController = getViewController(withIdentifier: authViewControllerIdentifier) as? AuthViewController
        else { return assertionFailure("Unable to get AuthViewController") }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard
            let window = UIApplication.shared.windows.first,
            let tabBarController = getViewController(withIdentifier: tabBarIdentifier) as? TabBarController
        else { return assertionFailure("Invalid configuration") }
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func getViewController(withIdentifier id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: id)
        return viewController
    }
    
    private func checkToken() {
        if let token = OAuth2TokenStorage.shared.token {
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
                self.alertPresenter?.showAlert()
                
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
                self.alertPresenter?.showAlert()
                self.presentAuthViewController()
            }
        }
    }
    
    private func fetchProfileImageURL(username: String) {
        profileImageService.fetchProfile(username) { result in
            switch result {
            case .success(let profileImageURL):
                NotificationCenter.default
                    .post(name: ProfileImageService.didChangeNotification,
                          object: self,
                          userInfo: ["URL" : profileImageURL])
            case .failure(_):
                self.alertPresenter?.showAlert()
            }
        }
    }
}
extension SplashViewController: ErrorAlertPresenterDelegate {
    func didPresentAlert(_ alert: UIAlertController?) {
        guard let alert = alert else { return }
        present(alert, animated: true, completion: nil)
    }
}
