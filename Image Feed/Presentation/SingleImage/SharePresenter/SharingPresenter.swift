import UIKit


protocol SharingPresenterProtocol: AnyObject {
    func requestSharingImage(for image: UIImage?)
}

protocol SharingPresenterDelegate: AnyObject {
    func shareImage(viewController: UIActivityViewController?)
}


final class SharingPresenter {
        
    //MARK: - Private properties
    private weak var delegate: SharingPresenterDelegate?
    
    //MARK: - Initializers
    init(delegate: SharingPresenterDelegate? = nil) {
        self.delegate = delegate
    }
}

//MARK: - SharingPresenterProtocol
extension SharingPresenter: SharingPresenterProtocol {
    func requestSharingImage(for image: UIImage?) {
        
        guard let image = image?.pngData() else {
            assertionFailure("Error image sharing")
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: [])
        delegate?.shareImage(viewController: activityViewController)
    }
}
