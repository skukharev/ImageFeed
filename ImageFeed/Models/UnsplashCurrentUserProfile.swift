//
//  UnsplashCurrentUserProfile.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 16.06.2024.
//

import Foundation

/// Структура ответа Unsplash при успешном выполнении запроса https://api.unsplash.com/me, получающего данные профиля текущего пользователя
struct UnsplashCurrentUserProfile: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}
