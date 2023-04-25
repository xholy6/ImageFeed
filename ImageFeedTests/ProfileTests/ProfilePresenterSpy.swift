import Foundation
@testable import Image_Feed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    var profileImageServiceObserver: NSObjectProtocol?
    var view: Image_Feed.ProfileViewProtocol?
    
    var viewDidLoadCalled = false
 
    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func createLogoutAlert() -> Image_Feed.AlertModel {
        return AlertModel(title: "test", message: "test", buttonText: "test", completion: nil)
    }
    
    func createLoadImageErrorAlert() -> Image_Feed.AlertModel {
        return AlertModel(title: "test", message: "test", buttonText: "test", completion: nil)
    }
    
}
