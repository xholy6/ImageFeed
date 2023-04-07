import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

protocol AuthViewControllerProtocol: AnyObject {
    func showWebviewController()
}

final class AuthViewController: UIViewController {
    
    //MARK: - Public properties
    weak var delegate: AuthViewControllerDelegate?
    
    //MARK: - @IBOutlet
    @IBOutlet private var singInButton: UIButton!
    
    //MARK: - Private properties
    private let segueIdentifier = "ShowWebView"
    private var authScreenView: AuthViewControllerScreen!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        authScreenView = AuthViewControllerScreen(viewController: self)
        setScreenViewOnViewController(view: authScreenView)
    }
}

//MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        dismiss(animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

extension AuthViewController: AuthViewControllerProtocol {
    func showWebviewController() {
        let webviewController = WebViewViewController()
        webviewController.delegate = self
        webviewController.modalPresentationStyle = .fullScreen
        present(webviewController, animated: true)
    }
}
