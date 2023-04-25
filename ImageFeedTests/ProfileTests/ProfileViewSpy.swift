import UIKit
@testable import Image_Feed

final class ProfileViewSpy: ProfileViewProtocol {
    
    var presenter: Image_Feed.ProfilePresenterProtocol?
    
    var updateProfileCalled = false
    var updateAvatarCalled = false
    
    func updateProfile(from profile: Image_Feed.Profile?) {
        updateProfileCalled = true
    }
    
    func updateAvatar(_ image: UIImage) {
        updateAvatarCalled = true
    }

    func requestShowAlertGetAvatarError(alertModel: Image_Feed.AlertModel) {}
}

