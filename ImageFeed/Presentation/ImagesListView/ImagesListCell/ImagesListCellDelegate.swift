//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 12.07.2024.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject {
    /// Обработчик события, генерируемого при нажатии пользователем на кнопку установки/снятия лайка на заданном фото
    /// - Parameters:
    ///   - cell: ячейка, в которой была нажата кнопка установки/снятия лайка
    ///   - withPhotoId: идентификатор фотографии в Unsplash
    func imageListCellDidTapLike(_ cell: ImagesListCell, _ completion: @escaping () -> Void)
}
