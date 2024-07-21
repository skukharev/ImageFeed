//
//  WebViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 10.06.2024.
//

import Foundation

protocol WebViewControllerDelegate: AnyObject {
    /// Сообщает делегату о том, что пользователь аутентифицировался в Unsplash
    /// - Parameters:
    ///   - viewController: Контроллер представления, отображающий страницу аутентификации Unsplash
    ///   - code: Код авторизации пользователя, возвращаемый сервером Unsplash
    func webViewController(_ viewController: WebViewController, didAuthenticateWithCode code: String)
    /// Сообщает делегату об ошибке загрузки окна аутентификации
    /// - Parameters:
    ///   - viewController: Контроллер представления, отображающий страницу аутентификации Unsplash
    ///   - didError: Ошибка отображения окна аутентификации
    func webViewController(_ viewController: WebViewController, didError: Error)
}
