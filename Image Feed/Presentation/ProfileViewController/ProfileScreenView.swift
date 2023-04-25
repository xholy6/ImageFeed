import UIKit
import Kingfisher

protocol ProfileViewProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfile(from profile: Profile?)
    func updateAvatar(_ image: UIImage)
    func requestShowAlertGetAvatarError(alertModel: AlertModel)
}

final class ProfileScreenView: UIView {
    
    weak var viewController: ProfileViewControllerProtocol?
    var presenter: ProfilePresenterProtocol?
    
    //MARK: - UI objects
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ProfileAvatar")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        return imageView
        
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "logoutButton"), for: .normal)
        button.accessibilityIdentifier = "Logout button"
        button.addTarget(self, action: #selector(didExitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginLabel: UILabel = {
        
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello World!"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Initializers
    init(frame: CGRect, viewController: ProfileViewControllerProtocol) {
        super.init(frame: frame)
        self.backgroundColor = .ypBlack
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewController = viewController
        let helper = ProfileHelper()
        presenter = ProfilePresenter(helper: helper)
        presenter?.view = self
        presenter?.viewDidLoad()
        addSubviews()
        constraintsActivate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private methods
    private func addSubviews() {
        addSubview(avatarImageView)
        addSubview(logoutButton)
        addSubview(loginLabel)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
    }
    
    private func constraintsActivate() {
        NSLayoutConstraint.activate([
            
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            logoutButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44)
            
            
        ])
    }
    
    @objc private func didExitButtonTapped() {
        guard let alertModel = presenter?.createLogoutAlert() else { return }
        viewController?.logoutProfile(alertModel: alertModel)
    }
}

//MARK: - ProfileViewProtocol
extension ProfileScreenView: ProfileViewProtocol {
    func updateAvatar(_ image: UIImage) {
        avatarImageView.image = image
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
    }
    
    func requestShowAlertGetAvatarError(alertModel: AlertModel) {
        self.viewController?.showAlertGetAvatarError(alertModel: alertModel)
    }
    
    func updateProfile(from profile: Profile?) {
        guard let profile else { return }
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
}
