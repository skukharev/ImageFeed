//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 17.07.2024.
//

import Foundation

protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewControllerProtocol? { get set }

    /// Обработчик загрузки вью контроллера
    func viewDidLoad()

    /// Обработчик ожидаемого процента загрузки страницы авторизации в Unsplash
    /// - Parameter newValue: Текущий процент загрузки страницы авторизации (от 0 до 1)
    func didUpdateProgressValue(_ newValue: Double)

    /// Обрабатывает ответ от страницы аутентификации Unsplash
    /// - Parameter url: url с ответом страницы аутентификации Unsplash
    /// - Returns: Возвращает код авторизации при успешной аутентификации; в противном случае - nil
    func code(from url: URL) -> String?
}
