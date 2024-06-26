//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 10.06.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
    case inTheExecution
}

final class OAuth2Service {
    // MARK: - Public Properties

    static let shared = OAuth2Service()

    // MARK: - Private Properties

    private var networkClient: NetworkClientProtocol
    private var lastCode: String?

    // MARK: - Initializers

    private init() {
        self.networkClient = NetworkClient()
    }

    // MARK: - Public Methods

    /// Получает Bearer-токен для авторизации в Unsplash
    /// - Parameters:
    ///   - code: Код авторизации, полученный при аутентификации в Unsplash (https://unsplash.com/oauth/authorize)
    ///   - handler: Обработчик, вызываемые по окончанию процесса авторизации в Unsplash
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread, "Вызов fetchOAuthToken должен производиться из главного потока во избежание гонки")

        if lastCode == code {
            handler(.failure(AuthServiceError.inTheExecution))
            return
        }

        guard let request = constructOAuthRequest(code: code) else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }

        lastCode = code

        networkClient.objectFetch(request: request) { [weak self] (result: Result<UnsplashToken, any Error>) in
            self?.lastCode = nil

            switch result {
            case .success(let token):
                handler(.success(token.accessToken))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    // MARK: - Private Methods

    /// Формирует ссылку для получения Bearer-токена авторизации "POST https://unsplash.com/oauth/token" согласно API Unsplash
    /// - Parameter code: Код, полученный при аутентификации в Unsplash
    /// - Returns: Сформированный URL для получения Bearer-токена
    private func constructOAuthRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashTokenURLString) else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]

        guard let url = urlComponents.url else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
