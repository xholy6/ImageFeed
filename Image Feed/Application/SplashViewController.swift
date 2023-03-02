import UIKit

final class SplashViewController: UIViewController {
    
    private let authenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let tabBarIdentifier = "TabBarViewController"
    
    //MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        OAuth2TokenStorage.shared.token != nil ? switchToTabBarController() : switchToAuthViewController()
    }
    
    //MARK: - Override method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == authenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else { return assertionFailure("Failed to prepare for \(authenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    //MARK: - Private methods
       private func switchToAuthViewController() {
           performSegue(withIdentifier: authenticationScreenSegueIdentifier, sender: nil)
       }

       private func switchToTabBarController() {
           guard let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration")}
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let tabBarVC = storyboard.instantiateViewController(withIdentifier: tabBarIdentifier)
           window.rootViewController = tabBarVC
       }
   }

   // MARK: AuthViewControllerDelegate
   extension SplashViewController: AuthViewControllerDelegate {
       func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
           OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
               guard let self = self else { return }
               switch result {
               case .success(let token):
                   self.switchToTabBarController()
                   print(token)
               case .failure(let error):
                   print(error)
               }
           }
       }
   }
