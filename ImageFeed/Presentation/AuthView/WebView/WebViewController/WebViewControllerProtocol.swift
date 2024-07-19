//
//  WebViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 17.07.2024.
//

import Foundation

protocol WebViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    /// Загружает заданную входным параметром страницу авторизации Unsplash
    /// - Parameter request: сформированный url страницы авторизации
    func load(request: URLRequest)
    /// Устанавливает заданное значение индикатору загрузки страницы авторизации Unsplash
    /// - Parameter newValue: Значение индикатора загрузки страницы авторизации
    func setProgressValue(_ newValue: Float)
    /// Скрывает либо отображает индикатор загрузки страницы авторизации Unsplash
    /// - Parameter isHidden: true - при необходимости скрыть индикатор загрузки; false -  противном случае
    func setProgressHidden(_ isHidden: Bool)
}
