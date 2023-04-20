import UIKit
import WebKit

protocol WebViewViewProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewControllerScreen: UIView {
    
    weak var viewController: WebViewViewControllerProtocol?
    var presenter: WebViewPresenterProtocol?
    
    //MARK: - UI object
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - UI object
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .white
        webView.accessibilityIdentifier = "UsplashWebView"
        return webView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "chevron.backward"), for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(didBackButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .ypBlack
        progressView.trackTintColor = .white
        return progressView
    }()
    
    // MARK: - Initializers
    init(frame: CGRect, viewController: WebViewViewControllerProtocol) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubViews()
        activateConstraints()
        
        self.viewController = viewController
        let authHelper = AuthHelper()
        self.presenter = WebViewPresenter(helper: authHelper)
        presenter?.view = self
        presenter?.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
             })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func addSubViews() {
        addSubview(webView)
        addSubview(backButton)
        addSubview(progressView)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 54),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.topAnchor.constraint(equalTo: backButton.topAnchor)
        ])
    }
    
    @objc private func didBackButtonTapped() {
        viewController?.dismissViewController()
    }
}

extension WebViewControllerScreen: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let code = code(from: navigationAction) {
            viewController?.getCode(code: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else { return nil}
        let code = presenter?.code(from: url)
        return code
    }
}

extension WebViewControllerScreen: WebViewViewProtocol {
    func load(request: URLRequest) {
        webView.load(request)
        webView.navigationDelegate = self
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}
