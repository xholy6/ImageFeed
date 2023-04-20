import XCTest
@testable import Image_Feed

final class WebViewTests: XCTestCase {
    func testViewControllerCallsDidLoad() {
        let sut = WebViewViewControllerSpy()
        let presenter = WebViewPresenterSpy()
        
        guard let view = sut.webviewScreen as? WebViewViewSpy else {
            XCTFail()
            return
        }
        
        view.presenter = presenter
        view.presenter?.view = view
        presenter.viewDidLoad()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenetrCallsLoadRequest() {
        let sut = WebViewViewControllerSpy()
        let helper = AuthHelper()
        let presenter = WebViewPresenter(helper: helper)
        
        guard let view = sut.webviewScreen as? WebViewViewSpy else {
            XCTFail()
            return
        }
        
        view.presenter = presenter
        view.presenter?.view = view
        presenter.viewDidLoad()
        
        XCTAssertTrue(view.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(helper: authHelper)
        let progress: Float = 0.6
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(helper: authHelper)
        let progress: Float = 1
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        let authHelper = AuthHelper()
        
        guard let url = authHelper.authURL() else {
            XCTFail()
            return
        }
        let urlString = url.absoluteString
        
        XCTAssertTrue(urlString.contains(AuthConfiguration.standart.unsplashAuthorizeURLString))
        XCTAssertTrue(urlString.contains(AuthConfiguration.standart.accessKey))
        XCTAssertTrue(urlString.contains(AuthConfiguration.standart.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(AuthConfiguration.standart.accessScope))
    }
    
    func testCodeFromURL() {
        var components = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        components?.queryItems = [
        URLQueryItem(name: "code", value: "test code")
        ]
        
        guard let url = components?.url else {
            XCTFail()
            return
        }
        
        let authHelper = AuthHelper()
        let code = authHelper.code(from: url)
        
        XCTAssertEqual(code, "test code")
    }
}
