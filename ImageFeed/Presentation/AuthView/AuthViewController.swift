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

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationControllerBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifer {
            guard let webViewController = segue.destination as? WebViewController else {
                assertionFailure("Экземпляр WebViewController не существует")
                return
            }
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - Private Methods

    private func configureNavigationControllerBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "backButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                navigationItem.backBarButtonItem?.tintColor = .ypWhite
            } else {
                navigationItem.backBarButtonItem?.tintColor = .ypBlack
            }
        }
    }
}

// MARK: - WebViewControllerDelegate
extension AuthViewController: WebViewControllerDelegate {
    func webViewController(_ viewController: WebViewController, didError: any Error) {
        print(#fileID, #function, #line, "Загрузка окна аутентификации завершилась с ошибкой \(didError)")
    }

    func webViewController(_ viewController: WebViewController, didAuthenticateWithCode code: String) {
        let utilityQueue = DispatchQueue(label: "oauth2ServiceQueue", qos: .utility)
        utilityQueue.async {[weak self] in
            guard let self = self else {
                return
            }
            self.oauth2Service.fetchOAuthToken(code: code) {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let token):
                        self.oauth2TokenStorage.token = token
                        self.delegate?.didAuthenticate(self)
                    case .failure(let error):
                        print(#fileID, #function, #line, "Процесс авторизации завершился с ошибкой \(error)")
                    }
                }
            }
        }
    }
}
