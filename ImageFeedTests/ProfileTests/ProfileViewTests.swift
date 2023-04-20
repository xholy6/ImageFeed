import XCTest
@testable import Image_Feed

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsDidLoad() {
        let sut = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        
        guard let view = sut.profileScreenView as? ProfileViewSpy else {
            XCTFail()
            return
        }
        
        view.presenter = presenter
        view.presenter?.view = view
        presenter.viewDidLoad()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testProfileViewCallsUpdateProfile() {
        let sut = ProfileViewControllerSpy()
        let helper = ProfileHelper()
        let presenter = ProfilePresenter(helper: helper)
        
        guard let view = sut.profileScreenView as? ProfileViewSpy else {
            XCTFail()
            return
        }
        
        view.presenter = presenter
        view.presenter?.view = view
        presenter.viewDidLoad()
        
        XCTAssertTrue(view.updateProfileCalled)
    }
    
    func testProfileViewCallsUpdateAvatar() {
        let sut = ProfileViewControllerSpy()
        let helper = ProfileHelper()
        let presenter = ProfilePresenter(helper: helper)
       
        guard let view = sut.profileScreenView as? ProfileViewSpy else {
            XCTFail()
            return
        }
        
        view.presenter = presenter
        view.presenter?.view = view
        presenter.viewDidLoad()
    
        XCTAssertTrue(view.updateAvatarCalled)
    }
}
