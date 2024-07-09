//
//  ImageListServiceDelegate.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 08.07.2024.
//

import Foundation

protocol ImagesListServiceDelegate: AnyObject {
    /// Массив со ссылками на отображаемые фотографии
    var photos: [Photo] { get }
    /// Загрузчик очередной порции фотографий в массив photos
    func fetchPhotosNextPage()
}
