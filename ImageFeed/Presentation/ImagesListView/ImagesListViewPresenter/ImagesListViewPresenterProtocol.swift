//
//  ImagesListViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 19.07.2024.
//

import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    var viewController: ImagesListViewPresenterDelegate? { get set }
    /// Изменяет состояние лайка изображения в Unsplash на противоположное
    /// - Parameters:
    ///   - cell: Ячейка ленты с фотографиями, для которой запрашивается операция изменения состояния лайка на противоположное
    ///   - completion: Обработчик, выполняемый при завершении операции изменения состояния лайка на противоположное
    func changeLike(for row: Int, _ completion: @escaping (Result<Bool, Error>) -> Void)
    /// Инициирует загрузку следующей порции фотографий в ленту
    func fetchPhotosNextPage()
    /// Возвращает url детального изображения фотографии из ленты фотографий
    /// - Parameter indexPath: Индекс ячейки ленты с фотографиями
    /// - Returns: url детального изображения
    func getImageDetailedURL(at indexPath: IndexPath) -> URL?
    /// Возвращает размер изображения для заданной ячейки ленты
    /// - Parameter indexPath: Индекс ячейки ленты с фотографиями
    /// - Returns: Размер изображения
    func getImageSizeByIndexPath(at indexPath: IndexPath) -> CGSize
    /// Используется для вычисления размера списка изображений
    /// - Returns: возвращает размер списка изображений
    func photosCount() -> Int
    /// Отображает заданную ячейку таблицы в табличном представлении
    /// - Parameters:
    ///   - cell: ссылка на отображаемую ячейку
    ///   - indexPath: Путь индекса строки в секции таблицы
    func showCell(for cell: ImagesListCell, with indexPath: IndexPath)
}
