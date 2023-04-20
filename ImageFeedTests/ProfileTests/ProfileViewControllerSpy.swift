import Foundation
@testable import Image_Feed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var profileScreenView: Image_Feed.ProfileViewProtocol?
    
    init(profileScreenView: Image_Feed.ProfileViewProtocol? = ProfileViewSpy()) {
        self.profileScreenView = profileScreenView
    }
    
    func showAlertGetAvatarError(alertModel: Image_Feed.AlertModel) {}
    
    func logoutProfile(alertModel: Image_Feed.AlertModel) {}
}
