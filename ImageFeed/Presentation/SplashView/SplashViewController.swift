//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 11.06.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties

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

        if OAuth2TokenStorage.shared.token != nil {
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
        // Создание вью контроллера для ленты изображений
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tab_editorial_active"), selectedImage: nil)
        let imagesListViewPresenter = ImagesListViewPresenter()
        imagesListViewController.configure(imagesListViewPresenter)
        // Создание вью контроллера для профиля пользователя
        let profileViewController = ProfileViewController()
        profileViewController.delegate = self
        profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tab_profile_active"), selectedImage: nil)
        let profileViewPresenter = ProfileViewPresenter()
        profileViewController.configure(profileViewPresenter)
        // Создание вью контроллера для таб-бара
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [imagesListViewController, profileViewController]
        // Настройка цвета фона таб-бара
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .ypBlack
        appearance.shadowColor = nil
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }

        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = tabBarController
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

// MARK: - ProfileViewControllerDelegate

extension SplashViewController: ProfileViewControllerDelegate {
    func didProfileLogout(_ viewController: UIViewController?) {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = self
    }
}
