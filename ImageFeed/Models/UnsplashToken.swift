//
//  UnsplashToken.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 10.06.2024.
//

import Foundation

/// Структура ответа Unsplash при успешном получении Bearer-токена. 
struct UnsplashToken: Codable {
    let accessToken: String
}
