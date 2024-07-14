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
    /// Устанавливает/снимает лайк на заданной фотографии в ленте
    /// - Parameters:
    ///   - photoId: Идентификатор фотографии
    ///   - isLike: Значение лайка
    ///   - completion: Обработчик, вызываемый после выполнения функции
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}
