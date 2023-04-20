import UIKit
import WebKit


protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

protocol WebViewViewControllerProtocol: AnyObject {
    var webviewScreen: WebViewViewProtocol? { get set }
    func dismissViewController()
    func getCode(code: String?)
}

final class WebViewViewController: UIViewController {
    
    //MARK: - Public properties
    weak var delegate: WebViewViewControllerDelegate?
    
    //MARK: - Private properties
    var webviewScreen: WebViewViewProtocol?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webviewScreen = WebViewControllerScreen(frame: .zero, viewController: self)
        
        guard let screenView = webviewScreen as? UIView else { return }
        setScreenViewOnViewController(view: screenView)
    }
}

extension WebViewViewController: WebViewViewControllerProtocol {
    
    func getCode(code: String?) {
        guard let code = code else { return }
        delegate?.webViewViewController(self, didAuthenticateWithCode: code)
    }
    
    func dismissViewController() {
        delegate?.webViewViewControllerDidCancel(self)
    }
}
