//
//  ProfileViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 18.07.2024.
//

import Foundation
import UIKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var viewController: ProfileViewPresenterDelegate? { get set }
    /// Обработчик нажатия на кнопку выхода из профиля пользователя
    func didLogoutButtonPressed()
    /// Загружает из Unsplash данные профиля пользователя
    func loadProfileData()
}
