//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 08.07.2024.
//

import Foundation

/// Загрузчик ленты фотографий из Unsplash
final class ImagesListService: ImagesListServiceDelegate {
    // MARK: - Types

    enum ImagesListServiceError: Error {
        case invalidRequest
        case urlRequestError(Error)
        case httpStatusCode(Int)
        case internalError
        case urlSessionError
    }

    // MARK: - Constants

    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    // MARK: - Public Properties

    private (set) var photos: [Photo] = []

    // MARK: - Private Properties

    /// Текущая загруженная страница с данными /photos
    private var lastLoadedPage: Int?
    /// Экземпляр загрузчика данных из Сети
    private var sessionTask: URLSessionTask?
    /// Bearer-токен авторизации в Unsplash
    private var accessToken: String?

    // MARK: - Initializers

    init() {
        self.lastLoadedPage = 0
        self.accessToken = OAuth2TokenStorage.shared.token
    }

    // MARK: - Public Methods

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread, "Вызов fetchPhotosNextPage должен производиться из главного потока во избежание гонки")

        if sessionTask != nil {
            return
        }

        guard
            let lastLoadedPage = lastLoadedPage,
            let accessToken = accessToken
        else {
            assertionFailure("Ошибка доступа к lastLoadedPage/accessToken")
            return
        }

        guard let request = constructPhotosRequest(withAccessToken: accessToken, page: lastLoadedPage + 1, perPage: 13) else {
            assertionFailure("Ошибка формирования запроса получения списка фотографий")
            return
        }

        sessionTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[UnsplashPhoto], any Error>) in
            switch result {
            case .success(let photosData):
                var imageSize = CGSize()
                let dateFormatter = ISO8601DateFormatter()

                for element in photosData {
                    imageSize.width = CGFloat(element.width ?? 0)
                    imageSize.height = CGFloat(element.height ?? 0)
                    let imageDescription = element.description ?? element.altDescription ?? ""
                    let imageDate = dateFormatter.date(from: element.createdAt ?? "") ?? Date()
                    let photo = Photo(id: element.id ?? "", size: imageSize, createdAt: imageDate, welcomeDescription: imageDescription, thumbImageURL: element.urls.thumb ?? "", largeImageURL: element.urls.full ?? "", isLiked: element.likedByUser ?? false)
                    self?.photos.append(photo)
                }
                self?.lastLoadedPage = (self?.lastLoadedPage ?? 0) + 1
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self, userInfo: ["Photos": self?.photos as Any])
                self?.sessionTask = nil
            case .failure(let error):
                print(#fileID, #function, #line, "[\(error.localizedDescription)]")
                return
            }
        }
        sessionTask?.resume()
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, any Error>) -> Void) {
        assert(Thread.isMainThread, "Вызов changeLike должен производиться из главного потока во избежание гонки")

        guard let accessToken = accessToken else {
            assertionFailure("Ошибка доступа к accessToken")
            completion(.failure(ImagesListServiceError.internalError))
            return
        }

        var request: URLRequest?
        if isLike {
            request = constructLikePhotoRequest(withAccessToken: accessToken, photoId: photoId)
        } else {
            request = constructUnlikePhotoRequest(withAccessToken: accessToken, photoId: photoId)
        }

        guard let request = request else {
            assertionFailure("Ошибка формирования запроса установки/снятия лайка для фотографии")
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }

        let sessionTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print(#fileID, #function, #line, "[\(ImagesListServiceError.urlRequestError(error).localizedDescription)]")
                completion(.failure(ImagesListServiceError.urlRequestError(error)))
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                print(#fileID, #function, #line, "[\(ImagesListServiceError.httpStatusCode(response.statusCode).localizedDescription)]")
                completion(.failure(ImagesListServiceError.httpStatusCode(response.statusCode)))
                return
            }
            guard data != nil else {
                print(#fileID, #function, #line, "[\(ImagesListServiceError.urlSessionError.localizedDescription)]")
                completion(.failure(ImagesListServiceError.urlSessionError))
                return
            }
            DispatchQueue.main.async {
                if let self = self, let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(id: photo.id, size: photo.size, createdAt: photo.createdAt, welcomeDescription: photo.welcomeDescription, thumbImageURL: photo.thumbImageURL, largeImageURL: photo.largeImageURL, isLiked: !photo.isLiked)
                    self.photos[index] = newPhoto
                }
            }
            completion(.success(()))
        }
        sessionTask.resume()
    }

    // MARK: - Private Methods

    /// Формирует ссылку для загрузки заданной порции данных о фотографиях из ленты фотографий Unsplash
    /// - Parameters:
    ///   - token: Bearer-токен авторизации в Unsplash
    ///   - page: Запрашиваемая страница с порцией данных о фотографиях
    ///   - perPage: Размер запрашиваемой порции данных с фотографиями. Значение по умолчанию - 10 фотографий
    /// - Returns: Сформированный URL для получения данных о фотографиях из ленты фотографий Unsplash
    private func constructPhotosRequest(withAccessToken token: String, page: Int, perPage: Int = 10) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashPhotosURLString) else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: page.description),
            URLQueryItem(name: "per_page", value: perPage.description)
        ]

        guard let url = urlComponents.url else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }

    /// Формирует ссылку для лайка фотографии
    /// - Parameters:
    ///   - token: Bearer-токен авторизации в Unsplash
    ///   - photoId: Идентификатор фотографии
    /// - Returns: Сформированный URL для установки лайка для заданной фотографии
    private func constructLikePhotoRequest(withAccessToken token: String, photoId: String) -> URLRequest? {
        guard let url = URL(string: Constants.unsplashLikePhotoURLString + "/" + photoId + "/like") else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        return request
    }

    /// Формирует ссылку для дизлайка фотографии
    /// - Parameters:
    ///   - token: Bearer-токен авторизации в Unsplash
    ///   - photoId: Идентификатор фотографии
    /// - Returns: Сформированный URL для снятия лайка для заданной фотографии
    private func constructUnlikePhotoRequest(withAccessToken token: String, photoId: String) -> URLRequest? {
        guard let url = URL(string: Constants.unsplashLikePhotoURLString + "/" + photoId + "/like") else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        return request
    }
}
