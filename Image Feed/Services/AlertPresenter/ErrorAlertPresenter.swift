import UIKit

protocol ErrorAlertPresenterDelegate: AnyObject {
    func didPresentAlert (_ alert: UIAlertController?)
}

protocol ErrorAlertPresenterProtocol {
    func showAlert()
}
struct ErrorAlertPresenter: ErrorAlertPresenterProtocol {
    
    weak var delegate: ErrorAlertPresenterDelegate?
    
    func showAlert() {
        guard let delegate = delegate else { return }
        
        let alertController = UIAlertController(title: "Что-то пошло не так",
                                                message: "Не удалось авторизироваться",
                                                preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) { _ in }
        
        alertController.addAction(action)
        delegate.didPresentAlert(alertController)
    }
}

