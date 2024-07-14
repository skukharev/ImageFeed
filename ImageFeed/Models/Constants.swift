//
//  Constants.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 09.06.2024.
//

import Foundation

/// Глобальные константы проекта
enum Constants {
    static let accessKey = "VFgSF7fgYnvg8uTpGVuZmB6Xi1fUnoG4us0DbJGuVLk"
    static let secretKey = "Qi8MPXn8w_nmzZG3WvXsJzlLVeW7pPDTYrIvtf5ppDE"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+read_photos+write_likes"
    static let defaultBaseURLString = "https://api.unsplash.com"
    static let defaultBaseAuthURLString = "https://unsplash.com/oauth"
    static let defaultBaseURL = URL(string: defaultBaseURLString)
    /// URL для авторизации в Unsplash
    static let unsplashAuthorizeURLString = defaultBaseAuthURLString + "/authorize"
    /// URL для генерации Bearer-токена в Unsplash
    static let unsplashTokenURLString = defaultBaseAuthURLString + "/token"
    /// URL для получения профиля текущего профиля
    static let unsplashMeURLString = defaultBaseURLString + "/me"
    /// URL для полученя публичного профиля заданного пользователя
    static let unsplashUsersProfileURLString = defaultBaseURLString + "/users"
    /// URL для получения списка фотографий
    static let unsplashPhotosURLString = defaultBaseURLString + "/photos"
    /// URL для установки лайка фотографии
    static let unsplashLikePhotoURLString = defaultBaseURLString + "/photos"
}
