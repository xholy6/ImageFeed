import UIKit

final class ProfileViewController: UIViewController {
    //MARK: - Private properties
    private var profileScreenView = ProfileScreenView()
    private var profileImageServiceObserver: NSObjectProtocol?
    private let token = OAuth2TokenStorage.shared.token
    private let profileService = ProfileService.shared
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main,
                         using: { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            })
            updateAvatar()
        
    }
    //MARK: - Private methods
    private func setupView() {
        view.backgroundColor = .ypBlack
        view.addSubview(profileScreenView)
        
        NSLayoutConstraint.activate([
            profileScreenView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            profileScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            profileScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
    private func updateProfileDetails(profile: Profile) {
        profileScreenView.updateProfile(from: profile)
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        profileScreenView.updateAvatar(url)
    }
}
