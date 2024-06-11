//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 10.06.2024.
//

import Foundation

final class OAuth2Service {
    // MARK: - Public Properties
    static let shared = OAuth2Service()

    // MARK: - Private Properties
    private let networkClient: NetworkClientProtocol

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
        guard let request = constructOAuthRequest(code: code) else { return }

        networkClient.fetch(request: request) {result in
            switch result {
            case .success(let data):
                do {
                    let token = try JSONDecoder().decode(UnsplashToken.self, from: data)
                    handler(.success(token.accessToken))
                } catch {
                    handler(.failure(error))
                }
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
