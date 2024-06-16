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

    // MARK: - Initializers

    init (viewController: ProfileViewPresenterDelegate? = nil) {
        self.viewController = viewController
    }

    // MARK: - Public Methods

    func loadProfileData() {
        let profileService = ProfileService.shared
        if let currentUserProfile = profileService.currentUserProfile {
            viewController?.showUserData(userProfile: currentUserProfile)
        }
//  TODO: Включить загрузку данных из сети после изучения анимации в 12 спринте
//        let profileService = ProfileService.shared
//        guard let accessToken = OAuth2TokenStorage.shared.token else {
//            assertionFailure("Bearer-токен не обнаружен в хранилище UserDefaults")
//            return
//        }
//
//        profileService.fetchCurrentUserProfile(withAccessToken: accessToken) { [weak self] result in
//            switch result {
//            case .success(let currentUserProfile):
//                self?.viewController?.showUserData(userProfile: currentUserProfile)
//            case .failure(let error):
//                print(#fileID, #function, #line, "Процесс получения данных профиля завершился с ошибкой \(error)")
//                self?.viewController?.showLoadingProfileError(withError: error)
//            }
//        }
    }
}
