//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 16.06.2024.
//

import Foundation

final class ProfileService {
    // MARK: - Types

    enum ProfileServiceError: Error {
        case invalidRequest
        case inTheExecution
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
        case convertDataError
    }

    // MARK: - Public Properties

    static let shared = ProfileService()

    var currentUserProfile: UnsplashCurrentUserProfile?

    // MARK: - Private Properties

    private var inTheFetchCurrentUserProfileRequest = false
    private var inTheFetchCurrentUserPublicPofileRequest = false
    private var username: String?

    // MARK: - Public Methods

    /// Получает профиль текущего пользователя, вызывая метод GET https://api.unsplash.com/me
    /// - Parameter handler: Обработчик, вызываемые по окончанию процесса авторизации в Unsplash
    func fetchCurrentUserProfile(withAccessToken token: String, handler: @escaping (Result<UnsplashCurrentUserProfile, Error>) -> Void) {
        assert(Thread.isMainThread, "Вызов fetchCurrentUserProfile должен производиться из главного потока во избежание гонки")

        if inTheFetchCurrentUserProfileRequest {
            handler(.failure(ProfileServiceError.inTheExecution))
            return
        }

        guard let request = constructMeRequest(withAccessToken: token) else {
            handler(.failure(ProfileServiceError.invalidRequest))
            return
        }

        let dataTask = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            self?.inTheFetchCurrentUserProfileRequest = false

            if let error = error {
                handler(.failure(ProfileServiceError.urlRequestError(error)))
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(ProfileServiceError.httpStatusCode(response.statusCode)))
                return
            }
            guard let data = data else {
                handler(.failure(ProfileServiceError.urlSessionError))
                return
            }

            do {
                let userProfileData = try SnakeCaseJSONDecoder().decode(UnsplashCurrentUserProfile.self, from: data)
                self?.username = userProfileData.username
                handler(.success(userProfileData))
            } catch {
                handler(.failure(ProfileServiceError.convertDataError))
            }
        }
        inTheFetchCurrentUserProfileRequest = true
        dataTask.resume()
    }

    /// Получает публичный профиль текущего пользователя, вызывая метод GET https://api.unsplash.com/users/:username
    /// - Parameter handler: Обработчик, вызываемые по окончанию процесса авторизации в Unsplash
    func fetchCurrentUserPublicPofile(withAccessToken token: String, handler: @escaping (Result<UnsplashUserPublicProfile, Error>) -> Void) {
        assert(Thread.isMainThread, "Вызов fetchCurrentUserPublicPofile должен производиться из главного потока во избежание гонки")

        if inTheFetchCurrentUserPublicPofileRequest {
            handler(.failure(ProfileServiceError.inTheExecution))
            return
        }

        guard
            let username = username,
            let request = constructUsersProfileRequest(withAccessToken: token, ofUser: username)
        else {
            handler(.failure(ProfileServiceError.invalidRequest))
            return
        }

        let dataTask = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            self?.inTheFetchCurrentUserPublicPofileRequest = false

            if let error = error {
                handler(.failure(ProfileServiceError.urlRequestError(error)))
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(ProfileServiceError.httpStatusCode(response.statusCode)))
                return
            }
            guard let data = data else {
                handler(.failure(ProfileServiceError.urlSessionError))
                return
            }

            do {
                let userProfileData = try SnakeCaseJSONDecoder().decode(UnsplashUserPublicProfile.self, from: data)
                handler(.success(userProfileData))
            } catch {
                handler(.failure(ProfileServiceError.convertDataError))
            }
        }
        inTheFetchCurrentUserPublicPofileRequest = true
        dataTask.resume()
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
