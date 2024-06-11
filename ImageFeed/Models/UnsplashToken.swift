//
//  UnsplashToken.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 10.06.2024.
//

import Foundation

/// Структура ответа Unsplash при успешном получении Bearer-токена. 
struct UnsplashToken: Codable {
    let accessToken, tokenType, refreshToken, scope: String
    let createdAt, userID: Int
    let username: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case scope
        case createdAt = "created_at"
        case userID = "user_id"
        case username
    }
}
