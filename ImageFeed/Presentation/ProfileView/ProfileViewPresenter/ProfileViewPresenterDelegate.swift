//
//  ProfileViewPresenterDelegate.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 16.06.2024.
//

import Foundation
import UIKit

protocol ProfileViewPresenterDelegate: AnyObject {
    /// Сообщает делегату о необходимости отобразить данные профиля пользователя
    /// - Parameter userProfile: Экземпляр UnsplashCurrentUserProfile с данными пользователя для отображения на экране
    func showUserData(userProfile: UnsplashCurrentUserProfile)
    /// Сообщает делегату о необходимости обновить фото профиля пользователя изображением, доступным по заданному URL
    /// - Parameter url: адрес изображения профиля пользователя
    func updateAvatar(withURL url: URL)
    /// Отображает алерт в окне делегата
    /// - Parameter alert: алерт для отображения
    func showAlert(_ alert: UIAlertController)
}
