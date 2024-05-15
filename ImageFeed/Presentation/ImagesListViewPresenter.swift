//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 15.05.2024.
//

import Foundation
import UIKit

final class ImagesListViewPresenter {
    weak private var viewController: ImagesListViewPresenterDelegate?

    private let photosName: [String] = Array(0..<20).map { "\($0)" }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    init (viewController: ImagesListViewPresenterDelegate? = nil) {
        self.viewController = viewController
    }

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
        var buttonPicture = UIImage()
        if row % 2 == 0 {
            buttonPicture = UIImage(named: "ActiveLikeButton") ?? UIImage()
        } else {
            buttonPicture = UIImage(named: "NoActiveLikeButton") ?? UIImage()
        }

        return ImagesListCellViewModel(image: picture, likeButtonImage: buttonPicture, dateLabel: dateFormatter.string(from: Date()))
    }

    /// Возвращает изображение для заданной ячейки ленты изображений
    /// - Parameter row: индекс ячейки ленты изображений
    /// - Returns: изображение UIImage
    func getImageByCellIndex(row: Int) -> UIImage {
        guard let image = UIImage(named: photosName[row]) else {
            return UIImage()
        }
        return image
    }
}
