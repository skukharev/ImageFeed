//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 16.06.2024.
//

import Foundation
import UIKit

final class ProfileViewPresenter {
    // MARK: - Private Properties

    weak private var viewController: ProfileViewPresenterDelegate?
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Initializers

    init (viewController: ProfileViewPresenterDelegate? = nil) {
        self.viewController = viewController

        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateAvatar()
        }
    }

    // MARK: - Public Methods

    func loadProfileData() {
        //  TODO: Удалить загрузку данных из profileService.currentUserProfile после изучения анимации в 12 спринте
        if let currentUserProfile = ProfileService.shared.currentUserProfile {
            viewController?.showUserData(userProfile: currentUserProfile)
        }
        guard let accessToken = OAuth2TokenStorage.shared.token else {
            assertionFailure("Bearer-токен не обнаружен в хранилище UserDefaults")
            return
        }

        ProfileService.shared.fetchCurrentUserProfile(withAccessToken: accessToken) { [weak self] result in
            switch result {
            case .success(let currentUserProfile):
                self?.viewController?.showUserData(userProfile: currentUserProfile)

                ProfileImageService.shared.fetchProfileImageURL(withAccessToken: accessToken, username: currentUserProfile.username) { _ in
                }
            case .failure(let error):
                print(#fileID, #function, #line, "Процесс получения данных профиля завершился с ошибкой \(error)")
                self?.viewController?.showLoadingProfileError(withError: error)
            }
        }
    }

    // MARK: - Private Methods
    private func updateAvatar() {
        guard
            let avatarURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: avatarURL)
        else { return }
        print("Загрузка и отображение аватара с адресом \(url)")

        viewController?.updateAvatar(withURL: url)
    }
}
