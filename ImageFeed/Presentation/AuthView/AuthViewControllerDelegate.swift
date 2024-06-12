//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 11.06.2024.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    /// Вызывается при успешной авторизации в Unsplash
    /// - Parameter viewController: экземпляр контроллера представления AuthViewController, в котором производится авторизация в Unsplash
    func didAuthenticate(_ viewController: AuthViewController)
}
