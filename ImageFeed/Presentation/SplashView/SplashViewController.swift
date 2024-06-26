//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 11.06.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties

    /// Сиснглетон для управления токеном авторизации в KeyChain
    private let oauth2TokenStorage = OAuth2TokenStorage.shared

    /// Элемент управления: картинка запуска приложения
    private lazy var launchScreen: UIImageView = {
        let launchScreen = UIImageView()
        launchScreen.translatesAutoresizingMaskIntoConstraints = false
        guard let image = UIImage(named: "LaunchScreen") else {
            assertionFailure("Ошибка загрузки изображения LaunchScreen")
            return launchScreen
        }
        launchScreen.image = image
        launchScreen.contentMode = .center
        return launchScreen
    }()

    // MARK: - UIViewController

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        createAndLayoutViews()

        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            switchToAuthenticateViewController()
        }
    }

    // MARK: - Private Methods

    /// Создаёт элементы управления
    private func addSubviews() {
        view.addSubview(launchScreen)
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .ypBlack
        addSubviews()
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Фото экрана запуска
            launchScreen.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            launchScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            launchScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            launchScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }

    /// Переключает rootViewController на список изображений Unsplash
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

        UIBlockingProgressHUD.show()
        let profileViewPresenter = ProfileViewPresenter(viewController: nil)
        profileViewPresenter.loadProfileData()
        UIBlockingProgressHUD.dismiss()
    }

    /// Переключает UI на страницу авторизации в приложении
    private func switchToAuthenticateViewController() {
        let navigationViewController = UINavigationController()
        let authViewController = AuthViewController()
        navigationViewController.viewControllers = [authViewController]
        authViewController.delegate = self
        navigationViewController.modalPresentationStyle = .fullScreen
        present(navigationViewController, animated: true)
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    /// Вызывается делегатом при ошибке авторизации в Unsplash
    /// - Parameter viewController: экземпляр AuthViewController, сгенерировавший событие
    func didAuthenticate(_ viewController: AuthViewController?) {
        viewController?.dismiss(animated: true)
        switchToTabBarController()
    }

    /// Вызывается делегатом при успешной авторизации в Unsplash
    /// - Parameter viewController: экземпляр AuthViewController, сгенерировавший событие
    func didAuthenticateWithError(_ viewController: AuthViewController?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController?.present(alert, animated: true)
        }
    }
}
