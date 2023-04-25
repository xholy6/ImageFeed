import Foundation
@testable import Image_Feed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: WebViewViewProtocol?
    
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    
    func code(from url: URL) -> String? {
        return nil
    }
}
