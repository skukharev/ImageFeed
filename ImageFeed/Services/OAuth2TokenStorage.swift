//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 11.06.2024.
//

import Foundation

/// Используется для хранения в UserDefaults Bearer-токена авторизации Unsplash
final class OAuth2TokenStorage {
    // MARK: - Public Properties
    static let shared = OAuth2TokenStorage()

    // MARK: - Initializers
    private init() {
    }

    // MARK: - Public Methods
    /// Bearer-токен авторизации в Unsplash
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "unsplashAccessToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "unsplashAccessToken")
        }
    }
}
