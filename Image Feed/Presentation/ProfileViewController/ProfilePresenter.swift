import Foundation
import WebKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewProtocol? { get set }
    var profileImageServiceObserver: NSObjectProtocol? { get set }
    func viewDidLoad()
    func createLogoutAlert() -> AlertModel
    func createLoadImageErrorAlert() -> AlertModel
}

final class ProfilePresenter {
    weak var view: ProfileViewProtocol?
    let helper: ProfileHelperProtocol

    var profileImageServiceObserver: NSObjectProtocol?
    private let profileService = ProfileService.shared

    init(helper: ProfileHelperProtocol) {
        self.helper = helper
    }
}

extension ProfilePresenter: ProfilePresenterProtocol {
    func viewDidLoad() {
        let profile = profileService.profile
        view?.updateProfile(from: profile)

        let profileImageURL = ProfileImageService.shared.avatarURL
        let url = URL(string: profileImageURL ?? "Error")

        if let image = UIImage(named: "placeholder") {
            self.view?.updateAvatar(image)
        }

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main,
                         using: { [weak self] _ in
                guard let self = self else { return }
                self.loadAvatarWithHelper(url: url)
            })
       loadAvatarWithHelper(url: url)
    }

    private func loadAvatarWithHelper(url: URL?) {
        helper.loadImage(url: url) { result in
            switch result {
            case .success(let image):
                self.view?.updateAvatar(image)
            case .failure(_):
                if let image = UIImage(named: "placeholder") {
                    self.view?.updateAvatar(image)
                }
                let alertModel = self.createLoadImageErrorAlert()
                self.view?.requestShowAlertGetAvatarError(alertModel: alertModel)
            }
        }
    }
}

//MARK: - Alert models
extension ProfilePresenter {
    func createLoadImageErrorAlert() -> AlertModel {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось загрузить аватар",
            buttonText: "Ok", completion: nil)
        return alertModel
    }

    func createLogoutAlert() -> AlertModel {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            buttonText: "Да") { [weak self] _ in
                guard let self = self else { return }
                UIBlockingProgressHUD.show()
                OAuth2TokenStorage.shared.removeToken()
                self.cleanCookies()
                self.showAuthViewController()
                ImageListService.shared.cleanPhotos()
                UIBlockingProgressHUD.dismiss()
            }
        return alertModel
    }


    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    private func showAuthViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration")}
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
    }
}
