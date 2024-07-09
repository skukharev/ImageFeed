//
//  UnsplashPhoto.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 08.07.2024.
//

import Foundation

struct Urls: Codable {
    let thumb: String?
    let full: String?
}

/// Структура ответа Unsplash при успешном выполнении запроса https://api.unsplash.com/photos, получающего страницу со списком фотографий из ленты фотографий
struct UnsplashPhoto: Codable {
    let id: String?
    let createdAt: String?
    let width, height: Int?
    let description: String?
    let altDescription: String?
    let urls: Urls
    let likedByUser: Bool?
}
