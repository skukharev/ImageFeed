//
//  ImagesListCellViewModel.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 15.05.2024.
//

import UIKit

/// Структура хранения элементов управления для ячейки таблицы
struct ImagesListCellViewModel {
    /// URL фото для ленты
    let thumbImageUrl: URL?
    /// URL фото для полноэкранного просмотра
    let fullImageUrl: URL?
    /// Изображение кнопки
    let likeButtonImage: UIImage
    /// Дата изображения ячейки
    let dateLabel: String
    /// Признак лайка фото
    let isLiked: Bool
}
