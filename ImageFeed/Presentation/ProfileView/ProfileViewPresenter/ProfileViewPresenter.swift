//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 16.06.2024.
//

import Foundation
import UIKit
import Kingfisher

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    // MARK: - Public Properties
    weak var viewController: ProfileViewPresenterDelegate?

    // MARK: - Private Properties

    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Initializers

    init () {
        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] notification in
            self?.updateAvatar(withURL: notification.userInfo?["URL"] as Any)
        }
    }

    // MARK: - Public Methods

    func didLogoutButtonPressed() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.logoutProfile()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        alert.preferredAction = alert.actions[safe: 1]
        viewController?.showAlert(alert)
    }

    func loadProfileData() {
        UIBlockingProgressHUD.show()
        //  TODO: Удалить загрузку данных из profileService.currentUserProfile после изучения анимации в 12 спринте
        if let currentUserProfile = ProfileService.shared.currentUserProfile {
            viewController?.showUserData(userProfile: currentUserProfile)
        }
        guard let accessToken = OAuth2TokenStorage.shared.token else {
            assertionFailure("Bearer-токен не обнаружен в хранилище KeyChain")
            return
        }

        ProfileService.shared.fetchCurrentUserProfile(withAccessToken: accessToken) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let currentUserProfile):
                self?.viewController?.showUserData(userProfile: currentUserProfile)

                ProfileImageService.shared.fetchProfileImageURL(withAccessToken: accessToken, username: currentUserProfile.username) { _ in }
            case .failure(let error):
                print(#fileID, #function, #line, "Процесс получения данных профиля завершился с ошибкой \(error)")
                let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось получить данные профиля пользователя", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.viewController?.showAlert(alert)
            }
        }
    }

    /// Реализует бизнес-логику по выходу из профиля пользователя
    func logoutProfile() {
        ProfileLogoutService.shared.logout()
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = SplashViewController()
    }

    // MARK: - Private Methods
    /// Инициирует загрузку и отображение фото профиля пользователя Unsplash
    private func updateAvatar(withURL: Any) {
        guard
            let avatarURL = withURL as? String?,
            let avatarURLAsString = avatarURL,
            let url = URL(string: avatarURLAsString)
        else {
            print(#fileID, #function, #line, "Unsplash вернул некорректную ссылку на фото профиля пользователя")
            return
        }
        viewController?.updateAvatar(withURL: url)
    }
}
