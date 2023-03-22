import UIKit

class SplashViewControllerScreen: UIView {
    //MARK: - UI object
 
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "Vector")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        return imageView
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

    // MARK: - Private methods
    private func addSubViews() {
        self.addSubview(logoImageView)
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}
