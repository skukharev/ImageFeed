//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 17.06.2024.
//

import Foundation

final class ProfileImageService {
    // MARK: - Types

    enum ProfileImageServiceError: Error {
        case invalidRequest
        case urlRequestError(Error)
        case convertDataError
    }

    // MARK: - Constants

    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    // MARK: - Public Properties

    private(set) var avatarURL: String?

    // MARK: - Private Properties

    private var sessionTask: URLSessionTask?

    // MARK: - Public Methods

    /// Получает публичный профиль текущего пользователя, вызывая метод GET https://api.unsplash.com/users/:username
    /// - Parameter handler: Обработчик, вызываемые по окончанию процесса авторизации в Unsplash
    func fetchProfileImageURL(withAccessToken token: String, username: String, handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread, "Вызов fetchCurrentUserPublicPofile должен производиться из главного потока во избежание гонки")

        if sessionTask != nil {
            sessionTask?.cancel()
        }

        guard let request = constructUsersProfileRequest(withAccessToken: token, ofUser: username) else {
            handler(.failure(ProfileImageServiceError.invalidRequest))
            return
        }

        sessionTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UnsplashUserPublicProfile, any Error>) in
            switch result {
            case .success(let userProfileData):
                self?.avatarURL = userProfileData.profileImage.small
                handler(.success(self?.avatarURL ?? ""))
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": self?.avatarURL as Any])
                self?.sessionTask = nil
            case .failure(let error):
                handler(.failure(ProfileImageServiceError.urlRequestError(error)))
                return
            }
        }
        sessionTask?.resume()
    }

    /// Очищает данные профиля
    func logout() {
        avatarURL = nil
    }

    // MARK: - Private Methods

    /// Формирует ссылку для получения информации о публичном профиле заданного пользователя "GET https://api.unsplash.com/users/" согласно API Unsplash
    /// - Parameter ofUser: имя пользователя, чей публичный профиль запрашивается
    /// - Returns: Сформированный URL для получения данных публичного профиля заданного пользователя
    private func constructUsersProfileRequest(withAccessToken token: String, ofUser: String) -> URLRequest? {
        guard let url = URL(string: Constants.unsplashUsersProfileURLString + "/" + ofUser) else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
