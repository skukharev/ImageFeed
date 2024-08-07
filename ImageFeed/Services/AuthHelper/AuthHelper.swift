//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 17.07.2024.
//

import Foundation

final class AuthHelper: AuthHelperProtocol {
    // MARK: - Constants

    let configuration: AuthConfiguration

    // MARK: - Initializers

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }


    // MARK: - Public Methods

    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }

        return URLRequest(url: url)
    }

    func code(from url: URL) -> String? {
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        } else {
            return nil
        }
    }

    // MARK: - Private Methods

    /// Формирует url авторизационного запроса к Unsplash в соответствии с п.п. 1 https://unsplash.com/documentation/user-authentication-workflow
    /// - Returns: Возвращает url авторизационного запроса либо nil в случае ошибки при формировании url
    private func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]

        guard let url = urlComponents.url else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return nil
        }

        return url
    }
}
