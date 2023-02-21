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
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        view.addSubview(profileScreenView)
        
        NSLayoutConstraint.activate([
            profileScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            profileScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            profileScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
}
