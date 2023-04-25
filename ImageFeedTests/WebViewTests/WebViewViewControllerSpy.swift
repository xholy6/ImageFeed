import Foundation
@testable import Image_Feed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var webviewScreen: Image_Feed.WebViewViewProtocol?
    
    init(webviewScreen: Image_Feed.WebViewViewProtocol? = WebViewViewSpy()) {
        self.webviewScreen = webviewScreen
    }
    
    func dismissViewController() {}
    
    func getCode(code: String?) {}
}
