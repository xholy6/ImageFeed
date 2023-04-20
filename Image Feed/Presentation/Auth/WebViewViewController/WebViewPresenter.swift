import Foundation

protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter {
    weak var view: WebViewViewProtocol?
    let helper: AuthHelperProtocol
    
    init(helper: AuthHelperProtocol) {
        self.helper = helper
    }
}

// MARK: - viewDidLoad
extension WebViewPresenter: WebViewPresenterProtocol {
    func viewDidLoad() {
        guard let request = helper.authRequest else {
            assertionFailure("Ошибка запроса для авторизации")
            return
        }
        didUpdateProgressValue(0)
        view?.load(request: request)
    }
}

//MARK: - UpdateProgress
extension WebViewPresenter {
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}

//MARK: - get code
extension WebViewPresenter {
    func code(from url: URL) -> String? {
        helper.code(from: url)
    }
}
