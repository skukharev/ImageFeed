//
//  UnsplashUserPublicProfile.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 16.06.2024.
//

import Foundation

struct ProfileImage: Codable {
    let small, medium, large: String?
}

///  Структура ответа Unsplash при успешном выполнении запроса https://api.unsplash.com/users/:username, получающего данные публичного профиля заданного пользователя
struct UnsplashUserPublicProfile: Codable {
    let profileImage: ProfileImage
}
