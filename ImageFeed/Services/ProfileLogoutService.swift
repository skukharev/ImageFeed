//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 11.07.2024.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    // MARK: - Constants
    static let shared = ProfileLogoutService()

    // MARK: - Public Methods

    /// Производит выход из профиля пользователя и очищает внутренние структуры от данных
    func logout() {
        cleanCookies()
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.logout()
        ImagesListService.shared.logout()
    }

    // MARK: - Private Methods

    /// Очищает кэш WebKit
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {}
            }
        }
    }
}
