//
//  Photo.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 08.07.2024.
//

import Foundation

/// Структура для хранения фотографии из ленты фотографий Unsplash
struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date
    let welcomeDescription: String
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
