//
//  ImagesListViewPresenterDelegate.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 15.05.2024.
//

import Foundation

/// Протокол делегата класса ImagesListViewPresenter
protocol ImagesListViewPresenterDelegate: AnyObject {
    /// Обработчик анимированного добавления строк в табличное представление
    func updateTableViewAnimated()

    /// Обработчик обновления высоты заданной ячейки ленты фотографий после загрузки
    /// - Parameter indexPath: Индекс обновляемой ячейки
    func updateHeightOfTableViewCell(at indexPath: IndexPath)
}
