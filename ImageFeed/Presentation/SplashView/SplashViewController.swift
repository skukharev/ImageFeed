//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 11.06.2024.
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    // MARK: - Private Properties
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let showAuthFlowSegueIdentifier = "ShowAuthFlow"

    // MARK: - Initializers
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthFlowSegueIdentifier, sender: nil)
        }
    }

    // MARK: - Overrides Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthFlowSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController else {
                assertionFailure("Ошибка обработки сегвея с ID=\(showAuthFlowSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - Public Methods
    func didAuthenticate(_ viewController: AuthViewController) {
        viewController.dismiss(animated: true)
        switchToTabBarController()
    }

    // MARK: - Private Methods
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}
