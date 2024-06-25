//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 16.06.2024.
//

import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
    case urlRequestError(Error)
    case convertDataError
    case dataLoadingIsWorking
}

final class ProfileService {
    // MARK: - Public Properties

    static let shared = ProfileService()

    private(set) var currentUserProfile: UnsplashCurrentUserProfile?

    // MARK: - Private Properties

    private var sessionTask: URLSessionTask?
    private var username: String?

    // MARK: - Public Methods

    /// Получает профиль текущего пользователя, вызывая метод GET https://api.unsplash.com/me
    /// - Parameter handler: Обработчик, вызываемые по окончанию процесса авторизации в Unsplash
    func fetchCurrentUserProfile(withAccessToken token: String, handler: @escaping (Result<UnsplashCurrentUserProfile, Error>) -> Void) {
        assert(Thread.isMainThread, "Вызов fetchCurrentUserProfile должен производиться из главного потока во избежание гонки")

        if sessionTask != nil {
            sessionTask?.cancel()
        }

        guard let request = constructMeRequest(withAccessToken: token) else {
            handler(.failure(ProfileServiceError.invalidRequest))
            return
        }

        sessionTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UnsplashCurrentUserProfile, Error>) in
            switch result {
            case .success(let userProfileData):
                self?.username = userProfileData.username
                self?.currentUserProfile = userProfileData
                handler(.success(userProfileData))
                self?.sessionTask = nil
            case .failure(let error):
                handler(.failure(ProfileServiceError.urlRequestError(error)))
                return
            }
        }
        sessionTask?.resume()
    }

    // MARK: - Private Methods

    /// Формирует ссылку для получения информации о профиле текущего пользователя "GET https://api.unsplash.com/me" согласно API Unsplash
    /// - Returns: Сформированный URL для получения данных профиля текущего пользователя
    private func constructMeRequest(withAccessToken token: String) -> URLRequest? {
        guard let url = URL(string: Constants.unsplashMeURLString) else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
