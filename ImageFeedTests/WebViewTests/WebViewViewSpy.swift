import Foundation
@testable import Image_Feed

final class WebViewViewSpy: WebViewViewProtocol {
    var presenter: Image_Feed.WebViewPresenterProtocol?
    
    var loadRequestCalled = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    
    func setProgressHidden(_ isHidden: Bool) {}
}

