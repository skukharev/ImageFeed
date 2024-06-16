//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 11.06.2024.
//

import Foundation
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    /// Вызывается при успешной авторизации в Unsplash
    /// - Parameter viewController: экземпляр контроллера представления AuthViewController, в котором производится авторизация в Unsplash
    func didAuthenticate(_ viewController: AuthViewController?)

    /// Вызывается при ошибке авторизации в Unsplash
    /// - Parameter viewController: экземпляр контроллера представления WebViewController, в котором производится аутентификация в Unsplash
    func didAuthenticateWithError(_ viewController: AuthViewController?)
}
