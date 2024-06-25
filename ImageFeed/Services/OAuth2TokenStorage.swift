//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 11.06.2024.
//

import Foundation
import SwiftKeychainWrapper

/// Используется для хранения в UserDefaults Bearer-токена авторизации Unsplash
final class OAuth2TokenStorage {
    // MARK: - Public Properties

    static let shared = OAuth2TokenStorage()

    // MARK: - Private Properties

    private let accessTokenKeyIdentifier = "unsplashAccessToken"

    // MARK: - Initializers

    private init() {
    }

    // MARK: - Public Methods

    /// Bearer-токен авторизации в Unsplash
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: accessTokenKeyIdentifier)
        }
        set {
            if let newValue = newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: accessTokenKeyIdentifier)
                guard isSuccess else {
                    assertionFailure("Ошибка записи токена в KeyChain")
                    return
                }
            } else {
                let isSuccess = KeychainWrapper.standard.removeObject(forKey: accessTokenKeyIdentifier)

                if !isSuccess {
                    assertionFailure("Ошибка удаления токена из KeyChain")
                    return
                }
            }
        }
    }
}
