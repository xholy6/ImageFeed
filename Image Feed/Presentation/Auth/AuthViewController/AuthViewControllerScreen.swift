import UIKit

final class AuthViewControllerScreen: UIView {
    
    weak var viewController: AuthViewControllerProtocol?
    
    // MARK: - UI object
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "Vector")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Войти", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.accessibilityIdentifier = "Authenticate"
        button.addTarget(self, action: #selector(didAuthButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .ypBlack
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubViews()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewController: AuthViewControllerProtocol) {
        self.init()
        self.viewController = viewController
    }
    
    // MARK: - Private methods
    private func addSubViews() {
        addSubview(signInButton)
        addSubview(logoImageView)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            signInButton.heightAnchor.constraint(equalToConstant: 48),
            signInButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            signInButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            signInButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -124)
        ])
    }
    
    @objc private func didAuthButtonTapped() {
        viewController?.showWebviewController()
    }
}
