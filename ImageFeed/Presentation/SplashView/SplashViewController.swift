//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 11.06.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties

    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let showAuthFlowSegueIdentifier = "ShowAuthFlow"

    // MARK: - UIViewController

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthFlowSegueIdentifier, sender: nil)
        }
    }

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

        // TODO: Выключить загрузку данных сразу после авторизации в Unsplash после изучения анимации в 12 спринте
        guard let token = oauth2TokenStorage.token else { return }
        UIBlockingProgressHUD.show()
        let profileService = ProfileService.shared
        profileService.fetchCurrentUserProfile(withAccessToken: token) { result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let currentUserProfile):
                    profileService.currentUserProfile = currentUserProfile
                case .failure(let error):
                    print(#fileID, #function, #line, "Процесс получения данных профиля завершился с ошибкой \(error)")
                }
            }
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ viewController: AuthViewController?) {
        viewController?.dismiss(animated: true)
        switchToTabBarController()
    }

    func didAuthenticateWithError(_ viewController: AuthViewController?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController?.present(alert, animated: true)
        }
    }
}
