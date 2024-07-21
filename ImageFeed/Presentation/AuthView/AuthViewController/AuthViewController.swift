//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 09.06.2024.
//

import UIKit

final class AuthViewController: UIViewController {
    // MARK: - Public Properties

    weak var delegate: AuthViewControllerDelegate?

    // MARK: - Private Properties

    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let showWebViewSegueIdentifer = "ShowWebView"
    private lazy var authorizationScreen: UIImageView = {
        let authScreen = UIImageView()
        authScreen.translatesAutoresizingMaskIntoConstraints = false
        authScreen.image = UIImage(named: "AuthorizationScreen")
        if authScreen.image == nil {
            assertionFailure("Ошибка загрузки изображения с идентификатором AuthorizationScreen")
            authScreen.image = UIImage()
        }
        authScreen.contentMode = .scaleAspectFit
        return authScreen
    }()
    private lazy var loginButton: UIButton = {
        let loginButton = UIButton(type: .system)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.contentHorizontalAlignment = .center
        loginButton.tintColor = .ypBlack
        loginButton.backgroundColor = .ypWhite
        loginButton.layer.cornerRadius = 16
        loginButton.addTarget(self, action: #selector(loginButtonTouchUpInside), for: .touchUpInside)
        loginButton.accessibilityIdentifier = "LoginButton"
        return loginButton
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        createAndLayoutViews()
        configureNavigationControllerBackButton()
    }

    // MARK: - Private Methods

    /// Создаёт элементы управления
    private func addSubViews() {
        view.addSubview(authorizationScreen)
        view.addSubview(loginButton)
    }

    /// Заменяет изображение и текст левой кнопки Navigation Controller по умолчанию
    private func configureNavigationControllerBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "backButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        self.view.backgroundColor = .ypBlack
        addSubViews()
        setupConstraints()
    }

    @objc private func loginButtonTouchUpInside() {
        let webViewController = WebViewController()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewController
        webViewController.delegate = self
        self.navigationController?.pushViewController(webViewController, animated: true)
    }

    /// Устанавливает констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Логотип Unsplash
            authorizationScreen.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
            authorizationScreen.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0),
            authorizationScreen.widthAnchor.constraint(equalToConstant: 60),
            authorizationScreen.heightAnchor.constraint(equalToConstant: 60),
            // Кнопка "Войти"
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -124),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

// MARK: - WebViewControllerDelegate
extension AuthViewController: WebViewControllerDelegate {
    func webViewController(_ viewController: WebViewController, didError: any Error) {
        print(#fileID, #function, #line, "Загрузка окна аутентификации завершилась с ошибкой \(didError)")
    }

    func webViewController(_ viewController: WebViewController, didAuthenticateWithCode code: String) {
        navigationController?.popViewController(animated: true)
        UIBlockingProgressHUD.show()

        oauth2Service.fetchOAuthToken(code: code) {[weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()

                switch result {
                case .success(let token):
                    self?.oauth2TokenStorage.token = token
                    self?.delegate?.didAuthenticate(self)
                case .failure(let error):
                    print(#fileID, #function, #line, "Процесс авторизации завершился с ошибкой \(error)")
                    if error as? AuthServiceError != .inTheExecution {
                        self?.delegate?.didAuthenticateWithError(self)
                    }
                }
            }
        }
    }
}
