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
    static let stubImageName = "ImageStub"

    // MARK: - Private Properties

    weak private var viewController: ImagesListViewPresenterDelegate?
    private var imagesListService: ImagesListServiceDelegate?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    // MARK: - Initializers

    init (viewController: ImagesListViewPresenterDelegate? = nil) {
        self.viewController = viewController

        NotificationCenter.default.addObserver(forName: ImagesListService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.viewController?.updateTableViewAnimated()
        }
        imagesListService = ImagesListService.shared
        imagesListService?.fetchPhotosNextPage()
    }

    // MARK: - Public Methods

    /// Используется для вычисления размера списка изображений
    /// - Returns: возвращает размер списка изображений
    func photosCount() -> Int {
        return imagesListService?.photos.count ?? 0
    }

    /// Метод конвертации который принимает индекс ячейки в таблице и возвращает вью модель изображения ленты изображений
    /// - Parameter row: Индекс ячейки в таблице
    /// - Returns: Структура с вью моделью изображения
    func convert(row: Int) -> ImagesListCellViewModel {
        let thumbImageUrl = URL(string: imagesListService?.photos[safe: row]?.thumbImageURL ?? "")
        let fullImageUrl = URL(string: imagesListService?.photos[safe: row]?.largeImageURL ?? "")
        let isLiked = imagesListService?.photos[safe: row]?.isLiked ?? false
        let buttonPictureName = isLiked ? "ActiveLikeButton" : "NoActiveLikeButton"
        let buttonPicture = UIImage(named: buttonPictureName) ?? UIImage()

        return ImagesListCellViewModel(thumbImageUrl: thumbImageUrl, fullImageUrl: fullImageUrl, likeButtonImage: buttonPicture, dateLabel: dateFormatter.string(from: imagesListService?.photos[safe: row]?.createdAt ?? Date()), isLiked: isLiked)
    }

    func getImageDetailedURL(at indexPath: IndexPath) -> URL? {
        return URL(string: imagesListService?.photos[safe: indexPath.row]?.largeImageURL ?? "")
    }

    /// Возвращает размер изображения для заданной ячейки ленты
    /// - Parameter indexPath: Индекс ячейки ленты с фотографиями
    /// - Returns: Размер изображения
    func getImageSizeByIndexPath(at indexPath: IndexPath) -> CGSize {
        guard let photoSize = imagesListService?.photos[safe: indexPath.row]?.size else {
            return CGSize(width: 0, height: 0)
        }
        return photoSize
    }

    /// Инициирует загрузку следующей порции фотографий в ленту
    func fetchPhotosNextPage() {
        imagesListService?.fetchPhotosNextPage()
    }

    /// Отображает заданную ячейку таблицы в табличном представлении
    /// - Parameters:
    ///   - cell: ссылка на отображаемую ячейку
    ///   - indexPath: Путь индекса строки в секции таблицы
    func showCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.setupCellPresentation()
        let cellViewModel = self.convert(row: indexPath.row)
        cell.showCellViewModel(cellViewModel) { [weak self] result in
            switch result {
            case .success:
                self?.viewController?.updateHeightOfTableViewCell(at: indexPath)
            case .failure: break
            }
        }
    }
}
