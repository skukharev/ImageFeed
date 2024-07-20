//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 17.07.2024.
//

import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {
    // MARK: - Public Properties

    weak var view: WebViewControllerProtocol?

    // MARK: - Private Properties

    private var authHelper: AuthHelperProtocol

    // MARK: - Initializers

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    // MARK: - Public Methods

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    /// Определяет критерии сокрытия progress view с view controller на основании процента загрузки страницы
    /// - Parameter value: Процент загрузки страницы. Значение от 0 (0%) до 1 (100%)
    /// - Returns: Возвращает true, если страница загружена и progress view необходимо скрыть; возвращает false в противном случае
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    func viewDidLoad() {
        guard let request = authHelper.authRequest() else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return
        }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
}
