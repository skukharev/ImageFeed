//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 15.05.2024.
//

import Foundation
import UIKit

final class ImagesListViewPresenter {
    // MARK: - Public Properties

    let photosName: [String] = Array(0..<20).map { "\($0)" }

    // MARK: - Private Properties

    weak private var viewController: ImagesListViewPresenterDelegate?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    // MARK: - Initializers

    init (viewController: ImagesListViewPresenterDelegate? = nil) {
        self.viewController = viewController
    }

    // MARK: - Public Methods

    /// Используется для вычисления размера списка изображений
    /// - Returns: возвращает размер списка изображений
    func photosCount() -> Int {
        return photosName.count
    }

    /// Метод конвертации который принимает индекс ячейки в таблице и возвращает вью модель изображения ленты изображений
    /// - Parameter row: Индекс ячейки в таблице
    /// - Returns: Структура с вью моделью изображения
    func convert(row: Int) -> ImagesListCellViewModel {
        let picture = UIImage(named: photosName[safe: row] ?? "") ?? UIImage()
        let buttonPictureName = (row % 2 != 0) ? "ActiveLikeButton" : "NoActiveLikeButton"
        let buttonPicture = UIImage(named: buttonPictureName) ?? UIImage()

        return ImagesListCellViewModel(image: picture, likeButtonImage: buttonPicture, dateLabel: dateFormatter.string(from: Date()))
    }

    /// Возвращает изображение для заданной ячейки ленты изображений
    /// - Parameter row: индекс ячейки ленты изображений
    /// - Returns: изображение UIImage
    func getImageByCellIndex(row: Int) -> UIImage {
        guard let image = UIImage(named: photosName[safe: row] ?? "") else {
            return UIImage()
        }
        return image
    }
}
