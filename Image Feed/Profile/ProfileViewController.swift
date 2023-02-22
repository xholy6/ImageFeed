import UIKit

final class ProfileViewController: UIViewController {
    //MARK: - Private properties
    private let profileScreenView = ProfileScreenView()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    //MARK: - Private method
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
}
