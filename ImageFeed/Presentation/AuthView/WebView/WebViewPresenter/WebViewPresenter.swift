//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 17.07.2024.
//

import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {
    // MARK: - Public Properties

    var view: WebViewControllerProtocol?

    // MARK: - Public Methods

    /// Обрабатывает ответ от страницы аутентификации Unsplash
    /// - Parameter url: url с ответом страницы аутентификации Unsplash
    /// - Returns: Возвращает код авторизации при успешной аутентификации; в противном случае - nil
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    func viewDidLoad() {
        guard let request = authHelper.authRequest() else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return
        }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }

    // MARK: - Private Properties
    private var authHelper: AuthHelperProtocol

    // MARK: - Initializers

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    // MARK: - Private Methods

    /// Определяет критерии сокрытия progress view с view controller на основании процента загрузки страницы
    /// - Parameter value: Процент загрузки страницы. Значение от 0 (0%) до 1 (100%)
    /// - Returns: Возвращает true, если страница загружена и progress view необходимо скрыть; возвращает false в противном случае
    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
